module UnitTests
  module Matchers
    def deprecate(old_method, new_method)
      DeprecateMatcher.new(old_method, new_method)
    end

    class DeprecateMatcher
      def initialize(old_method, new_method)
        @old_method = old_method
        @new_method = new_method
      end

      def matches?(block)
        @captured_stderr = capture(:stderr, &block).gsub(/\n+/, ' ')
        captured_stderr.include?(expected_message)
      end

      def failure_message
        "Expected block to #{expectation}, but it did not.\nActual warning: #{actual_warning}"
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

      attr_reader :old_method, :new_method, :captured_stderr

      private

      def expected_message
        "#{old_method} is deprecated and will be removed in the next major release. Please use #{new_method} instead."
      end

      def expectation
        "print a warning deprecating #{old_method} in favor of #{new_method}"
      end

      def actual_warning
        if captured_stderr.empty?
          "nothing"
        else
          "\n  #{captured_stderr}"
        end
      end
    end
  end
end
