begin
  require 'gpgme'
rescue LoadError
  begin
    require 'ruby_gpg'
  rescue LoadError
    raise "hiera-eyaml-gpg requires either the 'gpgme' or 'ruby_gpg' gem"
  end
  require 'hiera/backend/eyaml/encryptors/gpg/puppet_gpg'
end

require 'base64'
require 'pathname'
require 'hiera/backend/eyaml/encryptor'
require 'hiera/backend/eyaml/utils'
require 'hiera/backend/eyaml/options'

class Hiera
  module Backend
    module Eyaml
      module Encryptors
        class Gpg < Encryptor
          self.tag = 'GPG'

          self.options = {
            gnupghome: { desc: 'Location of your GNUPGHOME directory',
                         type: :string,
                         default: (%w[HOME HOMEPATH].reject { |h| ENV[h].nil? }.map { |h| ENV[h] + '/.gnupg' }.first || '').to_s },
            always_trust: { desc: 'Assume that used keys are fully trusted',
                            type: :boolean,
                            default: false },
            recipients: { desc: 'List of recipients (comma separated)',
                          type: :string },
            recipients_file: { desc: 'File containing a list of recipients (one on each line)',
                               type: :string }
          }

          @@passphrase_cache = {}

          def self.passfunc(_hook, uid_hint, _passphrase_info, _prev_was_bad, fd)
            system('stty -echo')

            unless @@passphrase_cache.key?(uid_hint)
              @@passphrase_cache[uid_hint] = ask("Enter passphrase for #{uid_hint}: ") { |q| q.echo = '' }
              $stderr.puts
            end
            passphrase = @@passphrase_cache[uid_hint]

            io = IO.for_fd(fd, 'w')
            io.puts(passphrase)
            io.flush
          ensure
            (0...$LAST_READ_LINE.length).each { |i| $LAST_READ_LINE[i] = '0' } if $LAST_READ_LINE
            system('stty echo')
          end

          def self.gnupghome
            gnupghome = if ENV['HIERA_EYAML_GPG_GNUPGHOME'].nil?
                          option :gnupghome
                        else
                          ENV['HIERA_EYAML_GPG_GNUPGHOME']
                        end
            debug("GNUPGHOME is #{gnupghome}")
            if gnupghome.nil? || gnupghome.empty?
              warn('No GPG home directory configured, check gpg_gnupghome configuration value is correct')
              raise ArgumentError, 'No GPG home directory configured, check gpg_gnupghome configuration value is correct'
            elsif !File.directory?(gnupghome)
              warn("Configured GPG home directory #{gnupghome} doesn't exist, check gpg_gnupghome configuration value is correct")
              raise ArgumentError, "Configured GPG home directory #{gnupghome} doesn't exist, check gpg_gnupghome configuration value is correct"
            else
              gnupghome
            end
          end

          def self.find_recipients
            recipient_option = option :recipients

            unless recipient_option.nil?
              debug('Using --recipients option')
              return recipient_option.split(',')
            end

            recipient_file_option = option :recipients_file
            recipient_file = if recipient_file_option.nil?
                               debug('Searching for any hiera-eyaml-gpg.recipients files in path')
                               find_recipient_file
                             else
                               debug('Using --recipients-file option')
                               Pathname.new(recipient_file_option)
                             end

            return [] if recipient_file.nil?

            recipient_file.readlines.map do |line|
              line.strip unless line.start_with?('#') || line.strip.empty?
            end.compact
          end

          def self.encrypt(plaintext)
            unless defined?(GPGME)
              raise RecoverableError, "Encryption is only supported when using the 'gpgme' gem"
            end

            GPGME::Engine.home_dir = gnupghome

            ctx = GPGME::Ctx.new

            recipients = find_recipients
            debug("Recipents are #{recipients}")

            raise RecoverableError, 'No recipients provided, don\'t know who to encrypt to' if recipients.empty?

            keys = recipients.map do |r|
              key_to_use = ctx.keys(r).first
              if key_to_use.nil?
                raise RecoverableError, "No key found on keyring for #{r}"
              end
              key_to_use
            end
            debug("Keys: #{keys}")

            always_trust = option(:always_trust)
            unless always_trust
              # check validity of recipients (this is possibly naive, but better than the unhelpful
              # error that it would spit out otherwise)
              keys.each do |key|
                unless key.primary_uid.validity >= GPGME::VALIDITY_FULL
                  raise RecoverableError, "Key #{key.sha} (#{key.email}) not trusted (if key trust is established by another means then specify always-trust)"
                end
              end
            end

            data = GPGME::Data.from_str(plaintext)
            crypto = GPGME::Crypto.new(always_trust: always_trust)

            ciphertext = crypto.encrypt(data, recipients: keys)
            ciphertext.seek 0
            ciphertext.read
          end

          def self.decrypt(ciphertext)
            gnupghome = self.gnupghome

            unless defined?(GPGME)
              gpg = Hiera::Backend::Eyaml::GpgPuppetserver
              gpg.config.homedir = gnupghome if gnupghome
              return gpg.decrypt_string(ciphertext)
            end

            GPGME::Engine.home_dir = gnupghome

            ctx = if hiera?
                    GPGME::Ctx.new
                  else
                    GPGME::Ctx.new(passphrase_callback: method(:passfunc))
                  end

            if !ctx.keys.empty?
              raw = GPGME::Data.new(ciphertext)
              txt = GPGME::Data.new

              begin
                txt = ctx.decrypt(raw)
              rescue GPGME::Error::DecryptFailed => e
                warn('Fatal: Failed to decrypt ciphertext (check settings and that you are a recipient)')
                raise e
              rescue Exception => e
                warn('Warning: General exception decrypting GPG file')
                raise e
              end

              txt.seek 0
              txt.read
            else
              warn("No usable keys found in #{gnupghome}. Check :gpg_gnupghome value in hiera.yaml is correct")
              raise ArgumentError, "No usable keys found in #{gnupghome}. Check :gpg_gnupghome value in hiera.yaml is correct"
            end
          end

          def self.create_keys
            STDERR.puts 'The GPG encryptor does not support creation of keys, use the GPG command lines tools instead'
          end

          private

          def self.find_recipient_file
             # if we are editing a file, look for a hiera-eyaml-gpg.recipients file
             filename = case Eyaml::Options[:source]
                        when :file
                          Eyaml::Options[:file]
                        when :eyaml
                          Eyaml::Options[:eyaml]
                        end

             return if filename.nil?

             root = Pathname.new(filename).realpath.dirname
             selected_file = nil
             root.descend do |path|
               potential_file = path.join('hiera-eyaml-gpg.recipients')
               selected_file = potential_file if potential_file.exist?
             end
             debug("Using file at #{selected_file}")
             selected_file
          end
        end
      end
    end
  end
end
