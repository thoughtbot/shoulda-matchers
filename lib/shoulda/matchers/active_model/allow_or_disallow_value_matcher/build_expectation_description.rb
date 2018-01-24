module Shoulda
  module Matchers
    module ActiveModel
      class AllowOrDisallowValueMatcher
        # @private
        class BuildExpectationDescription
          def self.call(matcher, **rest)
            new(matcher, **rest).call
          end

          def initialize(
            matcher,
            negated:,
            preface: default_preface
          )
            @matcher = matcher
            @negated = negated
            @preface = preface
          end

          def call
            "#{preface} #{expectation}."
          end

          private

          attr_reader :matcher, :preface

          def negated?
            @negated
          end

          def default_preface
            preface = ''

            if attribute_setter_clauses.any?
              preface << 'With '
              preface << attribute_setter_clauses.join(' and ')
              preface << ', the '
            else
              preface << 'The '
            end

            preface << "#{matcher.model} was expected"
          end

          def attribute_setter_clauses
            clauses = [
              clauses_for_values_to_preset,
              clauses_for_values_to_set,
            ]

            clauses.select(&:present?)
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

              clause <<
                if matcher.expected_message.is_a?(Regexp)
                  'placing an error matching '
                else
                  'placing the error '
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
