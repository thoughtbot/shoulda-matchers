module Shoulda
  module Matchers
    module ActiveModel
      class ValidationMatcher
        # @private
        class BuildDescription
          def self.call(matcher, main_description)
            new(matcher).call(main_description)
          end

          def initialize(matcher)
            @matcher = matcher
          end

          def call(main_description)
            if description_clauses_for_qualifiers.present?
              [main_description, description_clauses_for_qualifiers].join(', ')
            else
              main_description
            end
          end

          def description_clauses_for_qualifiers
            parts = [
              description_clause_for_allow_blank_or_nil,
              description_clause_for_strict_or_custom_validation_message,
            ]

            parts.select(&:present?).join(', and')
          end

          protected

          attr_reader :matcher

          private

          def description_clause_for_allow_blank_or_nil
            if expects_to_allow_blank?
              description_clause_for_allow_blank
            elsif expects_to_allow_nil?
              description_clause_for_allow_nil
            end
          end

          def description_clause_for_strict_or_custom_validation_message
            if expects_strict?
              description_clause_for_strict
            elsif expects_custom_validation_message?
              description_clause_for_custom_validation_message
            end
          end

          def description_clause_for_allow_blank
            'only if it is not blank'
          end

          def description_clause_for_allow_nil
            'only if it is not nil'
          end

          def description_clause_for_strict
            parts = []

            parts << 'raising a validation exception'

            if matcher.try(:expects_custom_validation_message?)
              parts << matcher.expected_message.inspect
            end

            parts << 'on failure'

            parts.join(' ')
          end

          def description_clause_for_custom_validation_message
            parts = [
              'producing a validation error',
              matcher.expected_message.inspect,
              'on failure',
            ]

            parts.join(' ')
          end

          def expects_to_allow_blank?
            matcher.try(:expects_to_allow_blank?)
          end

          def expects_to_allow_nil?
            matcher.try(:expects_to_allow_nil?)
          end

          def expects_strict?
            matcher.try(:expects_strict?)
          end

          def expects_custom_validation_message?
            matcher.try(:expects_custom_validation_message?)
          end
        end
      end
    end
  end
end
