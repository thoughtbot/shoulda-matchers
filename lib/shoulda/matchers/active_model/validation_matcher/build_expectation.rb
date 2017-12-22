module Shoulda
  module Matchers
    module ActiveModel
      class ValidationMatcher
        # @private
        class BuildExpectation
          def self.call(matcher, preface)
            new(matcher, preface).call
          end

          def initialize(matcher, preface)
            @matcher = matcher
            @preface = preface
            @build_description = BuildDescription.new(matcher)
          end

          def call
            parts.join(' ')
          end

          private

          attr_reader :preface, :matcher

          def parts
            [preface, 'with', clauses.select(&:present?).join(' and ')]
          end

          def clauses
            [
              expectation_clauses_for_values_to_preset,
              expectation_clauses_for_values_to_set,
            ]
          end

          def expectation_clauses_for_values_to_preset
            matcher.expectation_clauses_for_values_to_preset
          end

          def expectation_clauses_for_values_to_set
            matcher.expectation_clauses_for_values_to_set
          end
        end
      end
    end
  end
end
