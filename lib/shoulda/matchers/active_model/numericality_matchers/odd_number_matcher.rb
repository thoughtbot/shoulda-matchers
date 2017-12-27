module Shoulda
  module Matchers
    module ActiveModel
      module NumericalityMatchers
        # @private
        class OddNumberMatcher < NumericTypeMatcher
          NON_ODD_NUMBER_VALUE = 2

          def initialize(*args)
            super

            with_message(:odd)
          end

          def diff_to_compare
            2
          end

          protected

          def disallowed_value
            if numericality_matcher.given_numeric_column?
              NON_ODD_NUMBER_VALUE
            else
              NON_ODD_NUMBER_VALUE.to_s
            end
          end
        end
      end
    end
  end
end
