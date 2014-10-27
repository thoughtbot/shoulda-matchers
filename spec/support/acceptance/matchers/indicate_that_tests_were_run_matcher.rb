require_relative '../helpers/array_helpers'
require_relative '../helpers/pluralization_helpers'
require_relative '../helpers/rails_version_helpers'

module AcceptanceTests
  module Matchers
    def indicate_that_tests_were_run(series)
      IndicateThatTestsWereRunMatcher.new(series)
    end

    class IndicateThatTestsWereRunMatcher
      include ArrayHelpers
      include PluralizationHelpers
      include RailsVersionHelpers

      def initialize(args)
        @args = args
        @series = args.values
      end

      def matches?(runner)
        @runner = runner
        !matching_expected_output.nil?
      end

      def failure_message
        "Expected output to indicate that #{some_tests_were_run}.\n" +
          "#{formatted_expected_output}\n" +
          "#{formatted_actual_output}\n"
      end

      protected

      attr_reader :args, :series, :runner

      private

      def expected_outputs
        [
          expected_output_for_rails_3,
          expected_output_for_turn,
          expected_output_for_rails_4
        ]
      end

      def matching_expected_output
        @_matching_expected_output ||=
          expected_outputs.detect do |expected_output|
            actual_output =~ expected_output
          end
      end

      def expected_output_for_rails_3
        full_report = series.map do |number|
          "#{number} tests, #{number} assertions, 0 failures, 0 errors(, 0 skips)?"
        end.join('.+')

        Regexp.new(full_report, Regexp::MULTILINE)
      end

      def expected_output_for_turn
        full_report = series.map do |number|
          "pass: #{number},  fail: 0,  error: 0"
      end.join('.+')

        Regexp.new(full_report, Regexp::MULTILINE)
      end

      def expected_output_for_rails_4
        total = series.inject(:+)
        /#{total} (tests|runs), #{total} assertions, 0 failures, 0 errors(, 0 skips)?/
      end

      def formatted_expected_output
        if matching_expected_output
          "Expected output:\n#{matching_actual_output}"
        else
          "Expected output: (n/a)"
        end
      end

      def actual_output
        runner.output
      end

      def formatted_actual_output
        if actual_output.empty?
          "Actual output: (empty)"
        else
          "Actual output:\n#{actual_output}"
        end
      end

      def some_tests_were_run
        clauses = args.map do |type, number|
          pluralize(number, "#{type} test was run", "#{type} tests were run")
        end

        to_sentence(clauses)
      end
    end
  end
end
