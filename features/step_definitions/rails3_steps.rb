When /^I generate a new rails application$/ do
  @terminal.cd(TEMP_ROOT)
  @terminal.run("rails _3.0.3_ new #{APP_NAME}")
  steps %{
    When I save the following as "Gemfile"
      """
      source "http://rubygems.org"
      gem 'rails', '3.0.3'
      gem 'sqlite3-ruby', :require => 'sqlite3'
      """
  }
end

When /^I configure the application to use "([^\"]+)" from this project$/ do |name|
  append_to_gemfile "gem '#{name}', :path => '../../'"
  steps %{And I run "bundle install"}
end

When /^I run the "([^"]*)" generator$/ do |name|
  steps %{
    When I run "./script/rails generate #{name}"
  }
end

When /^I run the rspec generator$/ do
  steps %{
    When I run the "rspec:install" generator
  }
end

When /^I configure the application to use rspec\-rails$/ do
  append_to_gemfile "gem 'rspec-rails'"
  steps %{And I run "bundle install"}
end

When /^I configure a wildcard route$/ do
  steps %{
    When I save the following as "config/routes.rb"
    """
    Rails.application.routes.draw do |map|
      match ':controller(/:action(/:id(.:format)))'
    end
    """
  }
end

module AppendHelpers
  def append_to(path, contents)
    File.open(path, "a") do |file|
      file.puts
      file.puts contents
    end
  end

  def append_to_gemfile(contents)
    append_to(File.join(RAILS_ROOT, 'Gemfile'), contents)
  end
end

World(AppendHelpers)
