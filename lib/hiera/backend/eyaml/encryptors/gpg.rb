require 'gpgme'
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

          self.tag = "GPG"

          self.options = {
            :gnupghome => { :desc => "Location of your GNUPGHOME directory",
                            :type => :string,
                            :default => "#{ENV[["HOME", "HOMEPATH"].detect { |h| ENV[h] != nil }]}/.gnupg" },
            :always_trust => { :desc => "Assume that used keys are fully trusted",
                               :type => :boolean,
                               :default => false },
            :recipients => { :desc => "List of recipients (comma separated)",
                             :type => :string }
          }

          def self.eyaml?
            !Eyaml::Options[:source].nil?
          end

          def self.debug (msg)
            if eyaml?
              STDERR.puts msg
            else
              Hiera.debug("[eyaml_gpg]:  #{msg}")
            end
          end

          def self.warn (msg)
            if eyaml?
              STDERR.puts msg
            else
              Hiera.warn("[eyaml_gpg]:  #{msg}")
            end
          end

          def self.passfunc(hook, uid_hint, passphrase_info, prev_was_bad, fd)
            begin
                system('stty -echo')
                passphrase = ask("Enter passphrase for #{uid_hint}: ") { |q| q.echo = '*' }
                io = IO.for_fd(fd, 'w')
                io.puts(passphrase)
                io.flush
              ensure
                (0 ... $_.length).each do |i| $_[i] = ?0 end if $_
                  system('stty echo')
              end
              $stderr.puts
          end

          def self.find_recipients
            # if we are editing a file, look for a recipients.hiera-eyaml-gpg file
            filename = case Eyaml::Options[:source]
            when :file
              Eyaml::Options[:file]
            when :eyaml
              Eyaml::Options[:eyaml]
            else
              nil
            end

            if filename.nil? 
              []
            else
              path = Pathname.new(filename).realpath.dirname
              recipient_file = path.ascend.map { |path| 
                path.join('recipients.hiera-eyaml-gpg') 
              }.find { |file|
                file.exist? 
              }
              recipient_file.readlines unless recipient_file.nil?
              []
            end
          end

          def self.encrypt plaintext
            ENV["GNUPGHOME"] = self.option :gnupghome
            debug("GNUPGHOME is #{ENV['GNUPGHOME']}")

            ctx = GPGME::Ctx.new

            recipient_option = self.option :recipients
            recipients = unless recipient_option.nil?
              recipient_option.split(",")
            else
              self.find_recipients
            end
            debug("Recipents are #{recipients}")

            raise ArgumentError, 'No recipients provided, don\'t know who to encrypt to' if recipients.empty?

            keys = recipients.map {|r| ctx.keys(r).first }
            debug("Keys: #{keys}")

            always_trust = self.option(:always_trust)
            unless always_trust
              # check validity of recipients (this is possibly naive, but better than the unhelpful
              # error that it would spit out otherwise)
              keys.each do |key|
                unless key.primary_uid.validity >= GPGME::VALIDITY_FULL
                  raise StandardError, "Key #{key.sha} (#{key.email}) not trusted (if key trust is established by another means then specify always-trust)"
                end
              end
            end

            data = GPGME::Data.from_str(plaintext)
            crypto = GPGME::Crypto.new(:always_trust => always_trust)

            ciphertext = crypto.encrypt(data, :recipients => keys)
            ciphertext.seek 0
            ciphertext.read
          end

          def self.decrypt ciphertext
            ENV["GNUPGHOME"] = self.option :gnupghome
            debug("GNUPGHOME is #{ENV['GNUPGHOME']}")

            ctx = if eyaml?
              GPGME::Ctx.new
            else
              GPGME::Ctx.new(:passphrase_callback => method(:passfunc))
            end

            if !ctx.keys.empty?
              raw = GPGME::Data.new(ciphertext)
              txt = GPGME::Data.new

              begin
                  txt = ctx.decrypt(raw)
              rescue GPGME::Error::DecryptFailed
                  warn("Warning: GPG Decryption failed, check your GPG settings")
              rescue Exception => e
                  warn("Warning: General exception decrypting GPG file")
                  warn(e.message)
              end
              
              txt.seek 0
              result = txt.read

              debug("result is a #{result.class} ctx #{ctx} txt #{txt}")
              return result
            else
              warn("No usable keys found in #{ENV['GNUPGHOME']}. Check :gpgpghome value in hiera.yaml is correct")
            end
          end

          def self.create_keys
            STDERR.puts "The GPG encryptor does not support creation of keys, use the GPG command lines tools instead"
          end

        end

      end
    end
  end
end