require 'puppet'
require 'puppet/util/execution'
require 'puppet/file_system/uniquefile'

class Hiera
  module Backend
    module Eyaml
      module GpgPuppetserver
        extend RubyGpg

        def self.run_command(command, input = nil)
          tmpfile = Puppet::FileSystem::Uniquefile.new('puppet-eyaml-hiera-gpg-input', modes: File::WRONLY | File::BINARY)
          tmpfile.write(input)
          tmpfile.close

          real_command = "#{command} #{tmpfile.path}"

          output = Puppet::Util::Execution.execute(real_command, combine: false, failonfail: true)
          tmpfile.unlink

          if output.exitstatus != 0
            raise "GPG command (#{real_command}) failed with status #{output.exitstatus}: '#{output}'"
          end

          output
        end
      end
    end
  end
end
