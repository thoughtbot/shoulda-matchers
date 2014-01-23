module Shoulda
  module Matchers
    # @private
    module Integrations
      # @private
      module NUnitTestCaseDetection
        def self.possible_test_case_constants
          [
            -> { ActiveSupport::TestCase },
            -> { Minitest::Test },
            -> { MiniTest::Unit::TestCase },
            -> { Test::Unit::TestCase }
          ]
        end

        def self.resolve_constant(future_constant)
          future_constant.call
        rescue NameError
          nil
        end

        def self.detected_test_case_constants
          possible_test_case_constants.
            map { |future_constant| resolve_constant(future_constant) }.
            compact
        end

        def self.test_case_constants
          @_test_case_constants ||= detected_test_case_constants
        end
      end
    end

    # @private
    def self.nunit_test_case_constants
      Integrations::NUnitTestCaseDetection.test_case_constants
    end
  end
end
