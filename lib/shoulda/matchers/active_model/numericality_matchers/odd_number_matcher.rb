module Shoulda
  module Matchers
    module ActiveModel
      module NumericalityMatchers
        # @private
        class OddNumberMatcher < NumericTypeMatcher
          NON_ODD_NUMBER_VALUE  = 2

          def initialize(attribute, options = {})
            @attribute = attribute
            @disallow_value_matcher = DisallowValueMatcher.new(NON_ODD_NUMBER_VALUE).
                for(@attribute).
                with_message(:odd)
          end

          def allowed_type
            'odd numbers'
          end

          def diff_to_compare
            2
          end
        end
      end
    end
  end
end
