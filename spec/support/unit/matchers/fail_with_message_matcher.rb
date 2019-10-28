module UnitTests
  module Matchers
    extend RSpec::Matchers::DSL

    matcher :fail_with_message do |raw_expected, wrap: false|
      expected =
        if wrap
          Shoulda::Matchers.word_wrap(raw_expected)
        else
          raw_expected
        end

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

        @actual && @actual == expected.sub(/\n\z/, '')
      end

      define_method :failure_message do
        lines = ['Expectation should have failed with message:']
        lines << Shoulda::Matchers::Util.indent(expected, 2)

        if @actual
          diff = differ.diff(@actual, expected)[1..-1]

          lines << 'Actually failed with:'
          lines << Shoulda::Matchers::Util.indent(@actual, 2)

          if diff
            lines << 'Diff:'
            lines << Shoulda::Matchers::Util.indent(diff, 2)
          end
        else
          lines << 'However, the expectation did not fail at all.'
        end

        lines.join("\n")
      end

      define_method :failure_message_when_negated do
        lines = ['Expectation should not have failed with message:']
        lines << Shoulda::Matchers::Util.indent(expected, 2)
        lines.join("\n")
      end

      private

      def differ
        @_differ ||= RSpec::Support::Differ.new
      end
    end
  end
end
