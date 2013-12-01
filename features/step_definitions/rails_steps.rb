PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..', '..')).freeze
APP_NAME     = 'testapp'.freeze

BUNDLE_ENV_VARS = %w(RUBYOPT BUNDLE_PATH BUNDLE_BIN_PATH BUNDLE_GEMFILE)
ORIGINAL_BUNDLE_VARS = Hash[ENV.select{ |key,value| BUNDLE_ENV_VARS.include?(key) }]

Before do
  ENV['BUNDLE_GEMFILE'] = File.join(Dir.pwd, ENV['BUNDLE_GEMFILE']) unless ENV['BUNDLE_GEMFILE'].start_with?(Dir.pwd)
end

After do
  ORIGINAL_BUNDLE_VARS.each_pair do |key, value|
    ENV[key] = value
  end
end

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

When /^I configure the application to use "([^\"]+)" from this project$/ do |name|
  append_to_gemfile "gem '#{name}', :path => '#{PROJECT_ROOT}'"
  steps %{And I install gems}
end

When /^I configure the application to use "([^\"]+)" from this project in test and development$/ do |name|
  append_to_gemfile <<-GEMFILE
  group :test, :development do
    gem '#{name}', :path => '#{PROJECT_ROOT}'
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
  append_to_gemfile %q(gem 'rspec-rails', '~> 2.13')
  steps %{And I install gems}
end

When 'I configure the application to use rspec-rails in test and development' do
  append_to_gemfile <<-GEMFILE
  group :test, :development do
    gem 'rspec-rails', '~> 2.13'
  end
  GEMFILE
  steps %{And I install gems}
end

When 'I configure the application to use shoulda-context' do
  append_to_gemfile %q(gem 'shoulda-context', '~> 1.0')
  steps %{And I install gems}
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

When 'I reset Bundler environment variables' do
  BUNDLE_ENV_VARS.each do |key|
    ENV[key] = nil
  end
end

When /^I comment out the gem "([^"]*)" from the Gemfile$/ do |gemname|
  comment_out_gem_in_gemfile(gemname)
end

When /^I install gems$/ do
  steps %{When I run `bundle install --local`}
end

Then /^the output should indicate that (\d+) tests? (?:was|were) run/ do |number|
  # Rails 4 has slightly different output than Rails 3 due to
  # Test::Unit::TestCase -> MiniTest
  if rails_4?
    steps %{Then the output should contain "#{number} tests, #{number} assertions, 0 failures, 0 errors, 0 skips"}
  else
    steps %{Then the output should contain "#{number} tests, #{number} assertions, 0 failures, 0 errors"}
  end
end

Then /^the output should indicate that (\d+) unit and (\d+) functional tests? were run/ do |n1, n2|
  n1 = n1.to_i
  n2 = n2.to_i
  total = n1.to_i + n2.to_i
  # Rails 3 runs separate test suites in separate processes, but Rails 4 does
  # not, so that's why we have to check for different things here
  if rails_4?
    steps %{Then the output should contain "#{total} tests, #{total} assertions, 0 failures, 0 errors, 0 skips"}
  else
    steps %{Then the output should match /#{n1} tests, #{n1} assertions, 0 failures, 0 errors.+#{n2} tests, #{n2} assertions, 0 failures, 0 errors/}
  end
end

module FileHelpers
  def append_to(path, contents)
    in_current_dir do
      File.open(path, 'a') do |file|
        file.puts
        file.puts contents
      end
    end
  end

  def append_to_gemfile(contents)
    append_to('Gemfile', contents)
  end

  def comment_out_gem_in_gemfile(gemname)
    in_current_dir do
      gemfile = File.read('Gemfile')
      gemfile.sub!(/^(\s*)(gem\s*['"]#{gemname})/, "\\1# \\2")
      File.open('Gemfile', 'w'){ |file| file.write(gemfile) }
    end
  end

  def rails_4?
    match = ORIGINAL_BUNDLE_VARS['BUNDLE_GEMFILE'].match(/(\d)\.\d\.(\d\.)?gemfile$/)
    match.captures[0] == '4'
  end
end

World(FileHelpers)
