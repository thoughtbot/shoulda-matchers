require File.expand_path('../support/test_application', __FILE__)

$test_app = TestApplication.new
$test_app.create
$test_app.load

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
  config.include Shoulda::Matchers::ActionController,
                 example_group: { file_path: /action_controller/ }
end
