module Shoulda
  module Matchers
    module ActiveModel
      module NumericalityMatchers
        # @private
        class EvenNumberMatcher < NumericTypeMatcher
          NON_EVEN_NUMBER_VALUE = 1

          def initialize(attribute, options = {})
            @attribute = attribute
            @disallow_value_matcher = DisallowValueMatcher.new(NON_EVEN_NUMBER_VALUE).
                for(@attribute).
                with_message(:even)
          end

          def allowed_type
            'even numbers'
          end

          def diff_to_compare
            2
          end
        end
      end
    end
  end
end
