require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'appraisal'
require_relative 'tasks/documentation'

RSpec::Core::RakeTask.new('spec:unit') do |t|
  t.ruby_opts = '-w -r ./spec/report_warnings'
  t.pattern = "spec/unit/**/*_spec.rb"
  t.rspec_opts = '--color --format progress'
  t.verbose = false
end

RSpec::Core::RakeTask.new('spec:acceptance') do |t|
  t.ruby_opts = '-w -r ./spec/report_warnings'
  t.pattern = "spec/acceptance/**/*_spec.rb"
  t.rspec_opts = '--color --format progress'
  t.verbose = false
end

task :default do
  if ENV['BUNDLE_GEMFILE'] =~ /gemfiles/
    sh 'rake spec:unit'
    sh 'rake spec:acceptance'
  else
    Rake::Task['appraise'].invoke
  end
end

task :appraise do
  exec 'appraisal install && appraisal rake'
end

Shoulda::Matchers::DocumentationTasks.create

task release: 'docs:publish_latest'
