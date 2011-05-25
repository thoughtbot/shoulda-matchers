PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..', '..')).freeze
APP_NAME     = 'testapp'.freeze

BUNDLE_ENV_VARS = %w(RUBYOPT BUNDLE_PATH BUNDLE_BIN_PATH BUNDLE_GEMFILE)
ORIGINAL_BUNDLE_VARS = ENV.select{ |key,value| BUNDLE_ENV_VARS.include?(key) }

After do
  ORIGINAL_BUNDLE_VARS.each_pair do |key, value|
    ENV[key] = value
  end
end

When /^I generate a new rails application$/ do
  steps %{
    When I run `rails new #{APP_NAME}`
    And I cd to "#{APP_NAME}"
    And I append gems from Appraisal Gemfile
    And I reset Bundler environment variable
    And I successfully run `bundle install --local`
  }
end

When /^I configure the application to use "([^\"]+)" from this project$/ do |name|
  append_to_gemfile "gem '#{name}', :path => '#{PROJECT_ROOT}'"
  steps %{And I run `bundle install --local`}
end

When /^I run the rspec generator$/ do
  steps %{
    When I successfully run `rails generate rspec:install`
  }
end

When /^I configure the application to use rspec\-rails$/ do
  append_to_gemfile "gem 'rspec-rails', '~> 2.6.1.beta1'"
  steps %{And I run `bundle install --local`}
end

When /^I configure the application to use shoulda-context$/ do
  append_to_gemfile "gem 'shoulda-context', :git => 'git@github.com:thoughtbot/shoulda-context.git'"
  steps %{And I run `bundle install --local`}
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

When /^I append gems from Appraisal Gemfile$/ do
  File.read(ENV['BUNDLE_GEMFILE']).split(/\n/).each do |line|
    if line =~ /^gem "(?!rails|appraisal)/
      append_to_gemfile line.strip
    end
  end
end

When /^I reset Bundler environment variable$/ do
  BUNDLE_ENV_VARS.each do |key|
    ENV[key] = nil
  end
end

module FileHelpers
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

World(FileHelpers)
