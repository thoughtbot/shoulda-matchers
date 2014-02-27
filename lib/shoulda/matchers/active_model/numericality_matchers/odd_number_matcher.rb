module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      module NumericalityMatchers
        class OddNumberMatcher < NumericTypeMatcher # :nodoc:
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
