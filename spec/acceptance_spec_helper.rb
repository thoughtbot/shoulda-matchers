require_relative 'support/tests/current_bundle'

Tests::CurrentBundle.instance.assert_appraisal!

#---

require 'rspec/core'

require 'spec_helper'

Dir[ File.join(File.expand_path('../support/acceptance/**/*.rb', __FILE__)) ].sort.each do |file|
  require file
end

RSpec.configure do |config|
  if config.respond_to?(:infer_spec_type_from_file_location!)
    config.infer_spec_type_from_file_location!
  end

  AcceptanceTests::Helpers.configure_example_group(config)

  config.include AcceptanceTests::Matchers
end
