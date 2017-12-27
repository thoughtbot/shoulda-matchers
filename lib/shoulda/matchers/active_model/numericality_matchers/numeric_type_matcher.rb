require 'forwardable'

module Shoulda
  module Matchers
    module ActiveModel
      module NumericalityMatchers
        # @private
        class NumericTypeMatcher < ValidationMatcher
          def initialize(numericality_matcher, attribute)
            super(attribute)

            @numericality_matcher = numericality_matcher
          end

          def diff_to_compare
            raise NotImplementedError
          end

          protected

          attr_reader :numericality_matcher

          def add_submatchers
            add_submatcher_disallowing(disallowed_value)
          end

          def disallowed_value
            raise NotImplementedError
          end
        end
      end
    end
  end
end
