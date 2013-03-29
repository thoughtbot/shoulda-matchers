require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'appraisal'

RSpec::Core::RakeTask.new do |t|
  t.pattern = "spec/**/*_spec.rb"
  t.rspec_opts = '--color --format progress'
  t.verbose = false
end

Cucumber::Rake::Task.new do |t|
  t.fork = false
  t.cucumber_opts = ['--format', (ENV['CUCUMBER_FORMAT'] || 'progress')]
end

desc 'Default'
task :default => [:all]

desc 'Test the engine under all supported Rails versions'
task :all => ['appraisal:install'] do |t|
  exec 'rake appraisal spec cucumber'
end
