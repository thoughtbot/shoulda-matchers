RUBY_PROJECT_NAME = 'testproject'.freeze

When 'I generate a new Bundler project' do
  steps %{
    Given a directory named "#{RUBY_PROJECT_NAME}"
    When I cd to "#{RUBY_PROJECT_NAME}"
    And I write to "Gemfile" with:
      """
      source 'https://rubygems.org'
      gem 'rake', '>= 0.9.2'
      """
    And I reset Bundler environment variables
    And I set the "BUNDLE_GEMFILE" environment variable to "Gemfile"
  }
end

When /^I configure the project to use "(\w+)"$/ do |gem_name|
  append_to_gemfile %(gem '#{gem_name}')
  steps %{When I run `bundle install --local`}
end

When /^I configure the project to use "(\w+)" required via "(\w+)"/ do |gem_name, path|
  append_to_gemfile %(gem '#{gem_name}', require: '#{path}')
  steps %{When I run `bundle install --local`}
end

When 'I configure the project to use the shoulda-matchers from the root directory' do
  append_to_gemfile %(gem 'shoulda-matchers', path: '#{PROJECT_ROOT}')
  steps %{When I run `bundle install --local`}
end

When 'I configure the project to use RSpec' do
  append_to_gemfile %(gem 'rspec', '~> 2.0')
  steps %{
    When I run `bundle install --local`
    Given a directory named "spec"
    When I write to "spec/spec_helper.rb" with:
      """
      require 'bundler'
      Bundler.setup
      Bundler.require(:default)
      """
    And I write to "Rakefile" with:
      """
      require 'rspec/core/rake_task'
      RSpec::Core::RakeTask.new
      """
  }
end
