module UnitTests
  module Matchers
    def print_warning_including(expected_warning)
      PrintWarningIncludingMatcher.new(expected_warning)
    end

    class PrintWarningIncludingMatcher
      def initialize(expected_warning)
        @expected_warning = collapse_whitespace(expected_warning)
      end

      def matches?(block)
        @captured_stderr = collapse_whitespace(capture(:stderr, &block))
        captured_stderr.include?(expected_warning)
      end

      def failure_message
        "Expected block to #{expectation}\nbut actually printed#{actual_warning}"
      end
      alias_method :failure_message_for_should, :failure_message

      def failure_message_when_negated
        "Expected block not to #{expectation}, but it did."
      end
      alias_method :failure_message_for_should_not,
        :failure_message_when_negated

      def description
        "should #{expectation}"
      end

      def supports_block_expectations?
        true
      end

      protected

      attr_reader :expected_warning, :captured_stderr

      private

      def expectation
        "print a warning including:\n  #{expected_warning}"
      end

      def actual_warning
        if captured_stderr.empty?
          " nothing."
        else
          ":\n  #{captured_stderr}"
        end
      end

      def collapse_whitespace(string)
        string.gsub(/\n+/, ' ').squeeze(' ')
      end
    end
  end
end
