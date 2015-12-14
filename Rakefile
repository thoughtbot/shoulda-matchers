require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'appraisal'
require_relative 'tasks/documentation'
require_relative 'spec/support/tests/database'
require_relative 'spec/support/tests/current_bundle'

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
  if Tests::CurrentBundle.instance.appraisal_in_use?
    sh 'rake spec:unit --trace'
    sh 'rake spec:acceptance --trace'
  else
    if ENV['CI']
      exec "appraisal install && appraisal rake --trace"
    else
      appraisal = Tests::CurrentBundle.instance.latest_appraisal
      exec "appraisal install && appraisal #{appraisal} rake --trace"
    end
  end
end

Shoulda::Matchers::DocumentationTasks.create

task release: 'docs:publish_latest'
