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
        @should_be_negated = nil
      end

      def and_fail_with(message, wrap: false)
        @expected_message =
          if wrap
            Shoulda::Matchers.word_wrap(message.strip_heredoc.strip)
          else
            message.strip_heredoc.strip
          end

        @should_be_negated = true

        self
      end

      def or_fail_with(message, wrap: false)
        @expected_message =
          if wrap
            Shoulda::Matchers.word_wrap(message.strip_heredoc.strip)
          else
            message.strip_heredoc.strip
          end

        @should_be_negated = false

        self
      end

      def matches?(generate_matcher)
        @positive_matcher = generate_matcher.call
        @negative_matcher = generate_matcher.call

        if expected_message && should_be_negated?
          raise ArgumentError.new(
            'Use `or_fail_with`, not `and_fail_with`, when using ' +
            '`should match_against(...)`!',
          )
        end

        if positive_matcher.matches?(object)
          matcher_fails_in_negative?
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

        if expected_message && !should_be_negated?
          raise ArgumentError.new(
            'Use `and_fail_with`, not `or_fail_with`, when using ' +
            '`should_not match_against(...)`!',
          )
        end

        if matcher_fails_in_positive?
          if (
            negative_matcher.respond_to?(:does_not_match?) &&
            !negative_matcher.does_not_match?(object)
          )
            @failure_message_when_negated = <<-MESSAGE
Expected the matcher to match in the negative, but it failed with this message:

#{DIVIDER}
#{negative_matcher.failure_message_when_negated}
#{DIVIDER}
            MESSAGE
            false
          else
            true
          end
        end
      end

      def supports_block_expectations?
        true
      end

      private

      attr_reader(
        :object,
        :expected_message,
        :positive_matcher,
        :negative_matcher,
      )

      def should_be_negated?
        @should_be_negated
      end

      def matcher_fails_in_negative?
        if does_not_match_in_negative?
          if (
            !expected_message ||
            expected_message == negative_matcher.failure_message_when_negated.strip
          )
            true
          else
            diff_result = diff(
              expected_message,
              negative_matcher.failure_message_when_negated.strip,
            )
            @failure_message = <<-MESSAGE
Expected the negative version of the matcher not to match and for the failure
message to be:

#{DIVIDER}
#{expected_message.chomp}
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

      def does_not_match_in_negative?
        if negative_matcher.respond_to?(:does_not_match?)
          !negative_matcher.does_not_match?(object)
        else
          # generate failure_message_when_negated
          negative_matcher.matches?(object)
          true
        end
      end

      def matcher_fails_in_positive?
        if !positive_matcher.matches?(object)
          if (
            !expected_message ||
            expected_message == positive_matcher.failure_message.strip
          )
            true
          else
            diff_result = diff(
              expected_message,
              positive_matcher.failure_message.strip,
            )
            @failure_message_when_negated = <<-MESSAGE
Expected the positive version of the matcher not to match and for the failure
message to be:

#{DIVIDER}
#{expected_message.chomp}
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
