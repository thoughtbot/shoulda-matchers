When /^I configure the application to use "([^\"]+)"$/ do |name|
  append_to_gemfile "gem '#{name}'"
  steps %{And I install gems}
end

When /^I configure the application to use "([^\"]+)" from this project$/ do |name|
  append_to_gemfile "gem '#{name}', path: '#{PROJECT_ROOT}'"
  steps %{And I install gems}
end

When /^I configure the application to use "([^\"]+)" from this project, disabling auto-require$/ do |name|
  append_to_gemfile "gem '#{name}', path: '#{PROJECT_ROOT}', require: false"
  steps %{And I install gems}
end

When 'I configure the application to use shoulda-context' do
  append_to_gemfile %q(gem 'shoulda-context', '~> 1.2.0')
  append_to_gemfile %q(gem 'pry')
  steps %{And I install gems}
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
  if rails_lt_4?
    steps %{Then the output should contain "#{number} tests, #{number} assertions, 0 failures, 0 errors"}
  else
    steps %{Then the output should match /#{number} (tests|runs), #{number} assertions, 0 failures, 0 errors, 0 skips/}
  end
end

Then /^the output should indicate that (\d+) unit and (\d+) functional tests? were run/ do |n1, n2|
  n1 = n1.to_i
  n2 = n2.to_i
  total = n1.to_i + n2.to_i
  # Rails 3 runs separate test suites in separate processes, but Rails 4 does
  # not, so that's why we have to check for different things here
  if rails_lt_4?
    steps %{Then the output should match /#{n1} tests, #{n1} assertions, 0 failures, 0 errors.+#{n2} tests, #{n2} assertions, 0 failures, 0 errors/}
  else
    steps %{Then the output should match /#{total} (tests|runs), #{total} assertions, 0 failures, 0 errors, 0 skips/}
  end
end
