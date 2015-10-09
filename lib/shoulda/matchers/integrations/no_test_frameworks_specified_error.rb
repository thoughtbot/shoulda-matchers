module Shoulda
  module Matchers
    module Integrations
      # @private
      class NoTestFrameworksSpecifiedError < Shoulda::Matchers::Error
        protected

        def build_message
          <<-MESSAGE
shoulda-matchers is not configured correctly. You need to specify at least one
test framework. Please add the following to your test helper:

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose one:
    with.test_framework :rspec
    with.test_framework :minitest    # or, :minitest_5
    with.test_framework :minitest_4
    with.test_framework :test_unit
    with.test_framework :active_support_test_case
  end
end
          MESSAGE
        end
      end
    end
  end
end
