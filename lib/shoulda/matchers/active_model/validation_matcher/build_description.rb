module Shoulda
  module Matchers
    module ActiveModel
      class ValidationMatcher
        # @private
        class BuildDescription
          def self.call(matcher, main_description)
            new(matcher, main_description).call
          end

          def initialize(matcher, main_description)
            @matcher = matcher
            @main_description = main_description
          end

          def call
            if description_clauses_for_qualifiers.any?
              [main_description, description_clauses_for_qualifiers].join(', ')
            else
              main_description
            end
          end

          protected

          attr_reader :matcher, :main_description

          private

          def description_clauses_for_qualifiers
            description_clauses = []

            if matcher.try(:expects_to_allow_blank?)
              description_clauses << 'only if it is not blank'
            elsif matcher.try(:expects_to_allow_nil?)
              description_clauses << 'only if it is not nil'
            end

            if matcher.try(:expects_strict?)
              clause = ''

              if matcher.try(:expects_custom_validation_message?)
                clause << 'raising a validation exception '
                clause << matcher.expected_message.inspect
              else
                clause << 'raising a validation exception'
              end

              clause << ' on failure'

              description_clauses << clause
            elsif matcher.try(:expects_custom_validation_message?)
              clause = ''
              clause << 'producing a validation error '
              clause << matcher.expected_message.inspect
              clause << 'on failure'
              description_clauses << clause
            end

            description_clauses.join(', and')
          end
        end
      end
    end
  end
end
