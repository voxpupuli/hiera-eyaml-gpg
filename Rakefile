require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'github_changelog_generator/task'
require 'rbconfig'

desc 'Run RuboCop on the lib directory'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = ['lib/**/*.rb']
end

task test: %w[clean rubocop]

GitHubChangelogGenerator::RakeTask.new :changelog do |config|
  version = Hiera::Backend::Eyaml::Encryptors::GpgVersion::VERSION
  config.future_release = "v#{version}" if version =~ %r{^\d+\.\d+.\d+$}
  config.header = "# Changelog\n\nAll notable changes to this project will be documented in this file."
  config.exclude_labels = %w[duplicate question invalid wontfix wont-fix skip-changelog]
  config.user = 'voxpupuli'
  config.project = 'hiera-eyaml-gpg'
  config.since_tag = 'vp_migration'
end

# Workaround for https://github.com/github-changelog-generator/github-changelog-generator/issues/715
if RbConfig::CONFIG['host_os'] =~ /linux/
  task :changelog do
    puts 'Fixing line endings...'
    changelog_file = File.join(__dir__, 'CHANGELOG.md')
    changelog_txt = File.read(changelog_file)
    new_contents = changelog_txt.gsub(%r{\r\n}, "\n")
    File.open(changelog_file, "w") {|file| file.puts new_contents }
  end
end
