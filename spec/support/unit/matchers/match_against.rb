module UnitTests
  module Matchers
    def match_against(object)
      MatchAgainstMatcher.new(object)
    end

    class MatchAgainstMatcher
      DIVIDER = ('-' * Shoulda::Matchers::WordWrap::TERMINAL_WIDTH).freeze

      attr_reader :failure_message, :failure_message_when_negated

      def initialize(object)
        @object = object
        @failure_message = nil
        @failure_message_when_negated = nil
      end

      def and_fail_with(message)
        @message = message.strip
        self
      end
      alias_method :or_fail_with, :and_fail_with

      def matches?(generate_matcher)
        @positive_matcher = generate_matcher.call
        @negative_matcher = generate_matcher.call

        if positive_matcher.matches?(object)
          !message || matcher_fails_in_negative?
        else
          @failure_message = <<-MESSAGE
Expected the matcher to match in the positive, but it failed with this message:

#{DIVIDER}
#{positive_matcher.failure_message}
#{DIVIDER}
          MESSAGE
          false
        end
      end

      def does_not_match?(generate_matcher)
        @positive_matcher = generate_matcher.call
        @negative_matcher = generate_matcher.call

        if negative_matcher.does_not_match?(object)
          !message || matcher_fails_in_positive?
        else
          @failure_message_when_negated = <<-MESSAGE
Expected the matcher to match in the negative, but it failed with this message:

#{DIVIDER}
#{negative_matcher.failure_message_when_negated}
#{DIVIDER}
          MESSAGE
          false
        end
      end

      def supports_block_expectations?
        true
      end

      private

      attr_reader :object, :message, :positive_matcher, :negative_matcher

      def matcher_fails_in_negative?
        if !negative_matcher.does_not_match?(object)
          if message == negative_matcher.failure_message_when_negated.strip
            true
          else
            diff_result = diff(
              message,
              negative_matcher.failure_message_when_negated.strip,
            )
            @failure_message = <<-MESSAGE
Expected the negative version of the matcher not to match and for the failure
message to be:

#{DIVIDER}
#{message.chomp}
#{DIVIDER}

However, it was:

#{DIVIDER}
#{negative_matcher.failure_message_when_negated}
#{DIVIDER}

Diff:

#{Shoulda::Matchers::Util.indent(diff_result, 2)}
            MESSAGE
            false
          end
        else
          @failure_message =
            'Expected the negative version of the matcher not to match, ' +
            'but it did.'
          false
        end
      end

      def matcher_fails_in_positive?
        if !positive_matcher.matches?(object)
          if message == positive_matcher.failure_message.strip
            true
          else
            diff_result = diff(
              message,
              positive_matcher.failure_message.strip,
            )
            @failure_message_when_negated = <<-MESSAGE
Expected the positive version of the matcher not to match and for the failure
message to be:

#{DIVIDER}
#{message.chomp}
#{DIVIDER}

However, it was:

#{DIVIDER}
#{positive_matcher.failure_message}
#{DIVIDER}

Diff:

#{Shoulda::Matchers::Util.indent(diff_result, 2)}
            MESSAGE
            false
          end
        else
          @failure_message_when_negated =
            'Expected the positive version of the matcher not to match, ' +
            'but it did.'
          false
        end
      end

      def diff(expected, actual)
        differ.diff(expected, actual)[1..-1]
      end

      def differ
        @_differ ||= RSpec::Support::Differ.new
      end
    end
  end
end
