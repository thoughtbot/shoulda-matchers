PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..', '..')).freeze
APP_NAME     = 'testapp'.freeze

When /^I generate a new rails application$/ do
  steps %{
    When I run "rails _3.0.3_ new #{APP_NAME}"
    And I cd to "#{APP_NAME}"
    And I write to "Gemfile" with:
      """
      source "http://rubygems.org"
      gem 'rails', '3.0.3'
      gem 'sqlite3-ruby', :require => 'sqlite3'
      """
    And I successfully run "bundle install --local"
  }
end

When /^I configure the application to use "([^\"]+)" from this project$/ do |name|
  append_to_gemfile "gem '#{name}', :path => '#{PROJECT_ROOT}'"
  steps %{And I run "bundle install --local"}
end

When /^I run the rspec generator$/ do
  steps %{
    When I successfully run "rails generate rspec:install"
  }
end

When /^I configure the application to use rspec\-rails$/ do
  append_to_gemfile "gem 'rspec-rails'"
  steps %{And I run "bundle install --local"}
end

When /^I configure the application to use shoulda-context$/ do
  append_to_gemfile "gem 'shoulda-context', :git => 'git@github.com:thoughtbot/shoulda-context.git'"
  steps %{And I run "bundle install --local"}
end

When /^I configure a wildcard route$/ do
  steps %{
    When I write to "config/routes.rb" with:
    """
    Rails.application.routes.draw do
      match ':controller(/:action(/:id(.:format)))'
    end
    """
  }
end

module AppendHelpers
  def append_to(path, contents)
    in_current_dir do
      File.open(path, "a") do |file|
        file.puts
        file.puts contents
      end
    end
  end

  def append_to_gemfile(contents)
    append_to('Gemfile', contents)
  end
end

World(AppendHelpers)
