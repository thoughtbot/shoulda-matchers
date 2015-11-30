require_relative '../tests/current_bundle'
require_relative 'rails_application'

Tests::CurrentBundle.instance.assert_appraisal!

$test_app = UnitTests::RailsApplication.new
$test_app.create
$test_app.load

require 'active_record/base'

ENV['RAILS_ENV'] = 'test'
