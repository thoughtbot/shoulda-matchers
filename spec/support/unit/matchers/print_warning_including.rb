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
        @was_negated = false
        captured_stderr.include?(expected_warning)
      end

      def does_not_match?(block)
        !matches?(block).tap do
          @was_negated = true
        end
      end

      def failure_message
        "Expected block to #{expectation}\n\nHowever, #{aberration}"
      end

      def failure_message_when_negated
        "Expected block not to #{expectation}\n\nHowever, #{aberration}"
      end

      def description
        "should print a warning containing #{expected_warning.inspect}"
      end

      def supports_block_expectations?
        true
      end

      private

      attr_reader :expected_warning, :captured_stderr

      def was_negated?
        @was_negated
      end

      def expectation
        "print a warning containing:\n\n  #{expected_warning}"
      end

      def aberration
        if was_negated?
          'it did.'
        elsif captured_stderr.empty?
          'it actually printed nothing.'
        else
          "it actually printed:\n\n  #{captured_stderr}"
        end
      end

      def collapse_whitespace(string)
        string.gsub(/\n+/, ' ').squeeze(' ')
      end
    end
  end
end
