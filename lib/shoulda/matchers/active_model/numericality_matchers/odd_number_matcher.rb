module Shoulda
  module Matchers
    module ActiveModel
      module NumericalityMatchers
        # @private
        class OddNumberMatcher < NumericTypeMatcher
          NON_ODD_NUMBER_VALUE = 2

          def allowed_type
            'odd numbers'
          end

          def diff_to_compare
            2
          end

          protected

          def wrap_disallow_value_matcher(matcher)
            matcher.with_message(:odd)
          end

          def disallowed_value
            if @numeric_type_matcher.given_numeric_column?
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
