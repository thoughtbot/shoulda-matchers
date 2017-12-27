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
            description = decorate_with_validation_context(main_description)

            if description_clause_for_allow_blank_or_nil.present?
              description << " #{description_clause_for_allow_blank_or_nil}"
            end

            if description_clause_for_strict_or_custom_validation_message.present?
              description << ", #{description_clause_for_strict_or_custom_validation_message}"
            end

            description
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
            '(only when not blank)'
          end

          def description_clause_for_allow_nil
            '(only when not nil)'
          end

          def description_clause_for_strict
            'raising a validation exception on failure'
          end

          def description_clause_for_custom_validation_message
            parts = ['producing a validation error']

            parts <<
              if matcher.expected_message.is_a?(Regexp)
                "matching #{matcher.expected_message.inspect}"
              else
                matcher.expected_message.inspect
              end

            parts << 'on failure'

            parts.join(' ')
          end

          def decorate_with_validation_context(description)
            if validation_context.present?
              description.gsub(/\bvalidat(?:e|ion)\b/) do |str|
                "#{str} (context: #{validation_context.inspect})"
              end
            else
              description
            end
          end

          def validation_context
            matcher.try(:validation_context)
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
