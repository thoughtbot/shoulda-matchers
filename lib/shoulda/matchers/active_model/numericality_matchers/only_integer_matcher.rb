module Shoulda
  module Matchers
    module ActiveModel
      module NumericalityMatchers
        # @private
        class OnlyIntegerMatcher < NumericTypeMatcher
          NON_INTEGER_VALUE = 0.1

          def allowed_type
            'integers'
          end

          def diff_to_compare
            1
          end

          protected

          def wrap_disallow_value_matcher(matcher)
            matcher.with_message(:not_an_integer)
          end

          def disallowed_value
            if @numeric_type_matcher.given_numeric_column?
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
