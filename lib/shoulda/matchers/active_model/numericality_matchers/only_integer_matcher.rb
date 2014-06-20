module Shoulda
  module Matchers
    module ActiveModel
      module NumericalityMatchers
        # @private
        class OnlyIntegerMatcher < NumericTypeMatcher
          NON_INTEGER_VALUE = 0.1
          def initialize(attribute)
            @attribute = attribute
            @disallow_value_matcher = DisallowValueMatcher.new(NON_INTEGER_VALUE).
              for(attribute).
              with_message(:not_an_integer)
          end

          def allowed_type
            'integers'
          end

          def diff_to_compare
            1
          end
        end
      end
    end
  end
end
