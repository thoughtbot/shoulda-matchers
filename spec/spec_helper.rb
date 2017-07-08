PROJECT_ROOT = File.expand_path('../..', __FILE__)
$LOAD_PATH << File.join(PROJECT_ROOT, 'lib')

require 'pry'
require 'pry-byebug'

require 'rspec'

RSpec.configure do |config|
  config.order = :random

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.default_formatter = 'doc'

  config.mock_with :rspec
end

$VERBOSE = true
