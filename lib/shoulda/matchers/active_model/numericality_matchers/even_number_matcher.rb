module Shoulda
  module Matchers
    module ActiveModel
      module NumericalityMatchers
        # @private
        class EvenNumberMatcher < NumericTypeMatcher
          NON_EVEN_NUMBER_VALUE = 1

          def initialize(*args)
            super

            with_message(:even)
          end

          def diff_to_compare
            2
          end

          protected

          def disallowed_value
            if numericality_matcher.given_numeric_column?
              NON_EVEN_NUMBER_VALUE
            else
              NON_EVEN_NUMBER_VALUE.to_s
            end
          end
        end
      end
    end
  end
end
