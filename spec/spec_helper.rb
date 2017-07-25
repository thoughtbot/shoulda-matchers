PROJECT_ROOT = File.expand_path('../..', __FILE__)
$LOAD_PATH << File.join(PROJECT_ROOT, 'lib')

require 'pry'
require 'pry-byebug'

require 'rspec'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = :random
  config.default_formatter = 'doc'
  config.mock_with :rspec
  config.example_status_persistence_file_path = 'spec/examples.txt'
end

$VERBOSE = true
