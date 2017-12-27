module Shoulda
  module Matchers
    module ActiveModel
      module NumericalityMatchers
        # @private
        class OnlyIntegerMatcher < NumericTypeMatcher
          NON_INTEGER_VALUE = 0.1

          def initialize(*args)
            super

            with_message(:not_an_integer)
          end

          def diff_to_compare
            1
          end

          protected

          def disallowed_value
            if numericality_matcher.given_numeric_column?
              NON_INTEGER_VALUE
            else
              NON_INTEGER_VALUE.to_s
            end
          end
        end
      end
    end
  end
end
