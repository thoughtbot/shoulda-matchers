require_relative '../helpers/pluralization_helpers'
require_relative '../helpers/rails_version_helpers'

module AcceptanceTests
  module Matchers
    def indicate_number_of_tests_was_run(expected_output)
      IndicateNumberOfTestsWasRunMatcher.new(expected_output)
    end

    class IndicateNumberOfTestsWasRunMatcher
      include PluralizationHelpers
      include RailsVersionHelpers

      def initialize(number)
        @number = number
      end

      def matches?(runner)
        @runner = runner
        expected_output === actual_output
      end

      def failure_message
        message = "Expected output to indicate that #{some_tests_were_run}.\n" +
          "Expected output: #{expected_output}\n"

        if actual_output.empty?
          message << 'Actual output: (empty)'
        else
          message << "Actual output:\n#{actual_output}"
        end

        message
      end

      protected

      attr_reader :number, :runner

      private

      def expected_output
        /#{number} (tests|runs), #{number} assertions, 0 failures, 0 errors(, 0 skips)?/
      end

      def actual_output
        runner.output
      end

      def some_tests_were_run
        pluralize(number, 'test was', 'tests were') + ' run'
      end
    end
  end
end
