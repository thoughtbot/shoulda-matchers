module Shoulda
  module Matchers
    module ActiveModel
      class AllowOrDisallowValueMatcher
        # @private
        class BuildExpectationDescription
          def self.call(matcher, negated:)
            new(matcher, negated: negated).call
          end

          def initialize(matcher, negated:)
            @matcher = matcher
            @negated = negated
          end

          def call
            parts = [
              'With',
              attribute_setter_clauses + ',',
              'the',
              matcher.model,
              'was expected',
              expectation,
            ]

            parts.join(' ') + '.'
          end

          private

          attr_reader :matcher

          def negated?
            @negated
          end

          def attribute_setter_clauses
            clauses = [
              clauses_for_values_to_preset,
              clauses_for_values_to_set,
            ]

            clauses.select(&:present?).join(' and ')
          end

          def clauses_for_values_to_preset
            matcher.expectation_clauses_for_values_to_preset
          end

          def clauses_for_values_to_set
            matcher.expectation_clauses_for_values_to_set
          end

          def expectation
            if matcher.expects_custom_validation_message?
              expectation_with_expected_message
            else
              expectation_without_expected_message
            end
          end

          def expectation_with_expected_message
            parts = [
              to_or_not_to,
              'fail validation',
              context_clause,
              'by',
              error_message_clause,
            ]
            parts.select(&:present?).join(' ')
          end

          def to_or_not_to
            if negated?
              'to'
            else
              'not to'
            end
          end

          def context_clause
            if matcher.context.present?
              "(context: #{matcher.context.inspect})"
            end
          end

          def error_message_clause
            if matcher.expects_strict?
              'raising an exception'
            else
              clause = ''

              if matcher.expected_message.is_a?(Regexp)
                clause << 'placing an error matching '
              else
                clause << 'placing the error '
              end

              clause << "#{matcher.expected_message.inspect} "
              clause << "on :#{matcher.attribute_to_check_message_against}"
            end
          end

          def expectation_without_expected_message
            if negated?
              'be invalid'
            else
              'be valid'
            end
          end
        end
      end
    end
  end
end
