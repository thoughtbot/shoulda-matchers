require File.expand_path('../support/unit/rails_application', __FILE__)

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

$test_app = UnitTests::RailsApplication.new
$test_app.create
$test_app.load

monkey_patch_minitest_to_do_nothing

ENV['BUNDLE_GEMFILE'] ||= app.gemfile_path
ENV['RAILS_ENV'] = 'test'

require 'rspec/rails'
require 'shoulda-matchers'

PROJECT_ROOT = File.expand_path('../..', __FILE__)
$LOAD_PATH << File.join(PROJECT_ROOT, 'lib')

Dir[ File.join(File.expand_path('../support/unit/**/*.rb', __FILE__)) ].sort.each do |file|
  require file
end

RSpec.configure do |config|
  config.order = :random

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec

  if config.respond_to?(:infer_spec_type_from_file_location!)
    config.infer_spec_type_from_file_location!
  end

  config.before(:all, type: :controller) do
    self.class.controller(ApplicationController) { }
  end

  UnitTests::ActiveModelHelpers.configure_example_group(config)
  UnitTests::ActiveModelVersions.configure_example_group(config)
  UnitTests::ActiveResourceBuilder.configure_example_group(config)
  UnitTests::ClassBuilder.configure_example_group(config)
  UnitTests::ControllerBuilder.configure_example_group(config)
  UnitTests::I18nFaker.configure_example_group(config)
  UnitTests::MailerBuilder.configure_example_group(config)
  UnitTests::ModelBuilder.configure_example_group(config)
  UnitTests::RailsVersions.configure_example_group(config)
  UnitTests::ActiveRecordVersions.configure_example_group(config)
  UnitTests::ActiveModelVersions.configure_example_group(config)

  config.include UnitTests::Matchers
end

ActiveSupport::Deprecation.behavior = :stderr
$VERBOSE = true
