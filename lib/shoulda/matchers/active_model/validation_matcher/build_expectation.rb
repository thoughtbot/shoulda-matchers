module Shoulda
  module Matchers
    module ActiveModel
      class ValidationMatcher
        # @private
        class BuildExpectation
          def self.call(matcher, preface, **options)
            new(matcher, preface, **options).call
          end

          def initialize(matcher, preface, state:)
            @matcher = matcher
            @preface = preface

            @build_description = BuildDescription.new(
              matcher,
              expectation_state: state,
            )
          end

          def call
            parts = [
              [preface, 'with', clauses].join(' '),
              build_description.description_clauses_for_qualifiers,
            ]

            parts.select(&:present?).join(', ')
          end

          private

          attr_reader :preface, :matcher, :build_description

          def clauses
            clauses = [
              expectation_clauses_for_values_to_preset,
              expectation_clauses_for_values_to_set,
            ]

            clauses.select(&:present?).join(' and ')
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
