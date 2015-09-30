require 'shoulda/matchers/doublespeak'

PROJECT_ROOT = File.expand_path('../..', __FILE__)
$LOAD_PATH << File.join(PROJECT_ROOT, 'lib')

RSpec.configure do |config|
  config.order = :random

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.mock_with :rspec
end
