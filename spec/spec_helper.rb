require File.expand_path('../support/test_application', __FILE__)

def monkey_patch_minitest_to_do_nothing
  # Rails 3.1's test_help file requires Turn, which loads Minitest in autorun
  # mode. This means that Minitest tests will run after these RSpec tests are
  # finished running. This will break on CI since we pass --color to the `rspec`
  # command.

  if defined?(MiniTest)
    MiniTest::Unit.class_eval do
      def run(*); end
    end
  end
end

$test_app = TestApplication.new
$test_app.create
$test_app.load

monkey_patch_minitest_to_do_nothing

ENV['BUNDLE_GEMFILE'] ||= app.gemfile_path
ENV['RAILS_ENV'] = 'test'

require 'bourne'
require 'shoulda-matchers'
require 'rspec/rails'

PROJECT_ROOT = File.expand_path('../..', __FILE__)
$LOAD_PATH << File.join(PROJECT_ROOT, 'lib')

Dir[ File.join(PROJECT_ROOT, 'spec/support/**/*.rb') ].each { |file| require file }
RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :mocha
  config.include Shoulda::Matchers::ActionController, type: :controller
end

$VERBOSE = true
