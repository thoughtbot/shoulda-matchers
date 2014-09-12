When 'I generate a new rails application' do
  steps %{
    When I run `bundle exec rails new #{APP_NAME} --skip-bundle`
    And I cd to "#{APP_NAME}"
    And I comment out the gem "turn" from the Gemfile
    And I comment out the gem "coffee-rails" from the Gemfile
    And I comment out the gem "uglifier" from the Gemfile
    And I reset Bundler environment variables
    And I set the "BUNDLE_GEMFILE" environment variable to "Gemfile"
    And I install gems
  }

  if RUBY_VERSION >= '1.9.3'
    append_to_gemfile %(gem 'rake', '~> 0.9')
    step %(I successfully run `bundle update rake`)
  end
end

When 'I configure the application to use Spring' do
  if rails_lt_4?
    append_to_gemfile "gem 'spring'"
    steps %{And I install gems}
  end
end

When /^I configure the application to use "([^\"]+)" from this project in test and development$/ do |name|
  append_to_gemfile <<-GEMFILE
  group :test, :development do
    gem '#{name}', path: '#{PROJECT_ROOT}'
  end
  GEMFILE
  steps %{And I install gems}
end

When 'I run the rspec generator' do
  steps %{
    When I successfully run `rails generate rspec:install`
  }
end

When 'I configure the application to use rspec-rails' do
  append_to_gemfile <<-GEMFILE
  gem 'rspec-rails', '#{rspec_rails_version}'
  GEMFILE
  steps %{And I install gems}
end

When 'I configure the application to use rspec-rails in test and development' do
  append_to_gemfile <<-GEMFILE
  group :test, :development do
    gem 'rspec-rails', '#{rspec_rails_version}'
  end
  GEMFILE
  steps %{And I install gems}
end

When 'I require shoulda-matchers following rspec-rails' do
  insert_line_after test_helper_path,
    "require 'rspec/rails'",
    "require 'shoulda/matchers'"
end

When /^I set the "([^"]*)" environment variable to "([^"]*)"$/ do |key, value|
  ENV[key] = value
end

When 'I configure a wildcard route' do
  steps %{
    When I write to "config/routes.rb" with:
    """
    Rails.application.routes.draw do
      get ':controller(/:action(/:id(.:format)))'
    end
    """
  }
end

When 'I append gems from Appraisal Gemfile' do
  File.read(ENV['BUNDLE_GEMFILE']).split("\n").each do |line|
    if line =~ /^gem "(?!rails|appraisal)/
      append_to_gemfile line.strip
    end
  end
end
