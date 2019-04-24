require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'github_changelog_generator/task'

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
