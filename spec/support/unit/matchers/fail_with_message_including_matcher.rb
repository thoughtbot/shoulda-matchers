module UnitTests
  module Matchers
    extend RSpec::Matchers::DSL

    matcher :fail_with_message_including do |expected|
      def supports_block_expectations?
        true
      end

      match do |block|
        @actual = nil

        begin
          block.call
        rescue RSpec::Expectations::ExpectationNotMetError => ex
          @actual = ex.message
        end

        @actual && @actual.include?(expected)
      end

      def failure_message
        lines = ['Expectation should have failed with message including:']
        lines << Shoulda::Matchers::Util.indent(expected, 2)

        if @actual
          lines << 'The full message was:'
          lines << Shoulda::Matchers::Util.indent(@actual, 2)
        else
          lines << 'However, the expectation did not fail at all.'
        end

        lines.join("\n")
      end

      def failure_message_for_should
        failure_message
      end

      def failure_message_when_negated
        lines = ['Expectation should not have failed with message including:']
        lines << Shoulda::Matchers::Util.indent(expected, 2)
        lines.join("\n")
      end

      def failure_message_for_should_not
        failure_message_when_negated
      end
    end
  end
end
