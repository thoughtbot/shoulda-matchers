module Shoulda
  module Matchers
    module ActiveModel
      # @private
      module NumericalityMatchers
        autoload :ComparisonMatcher,  'shoulda/matchers/active_model/numericality_matchers/comparison_matcher'
        autoload :EvenNumberMatcher,  'shoulda/matchers/active_model/numericality_matchers/even_number_matcher'
        autoload :NumericTypeMatcher, 'shoulda/matchers/active_model/numericality_matchers/numeric_type_matcher'
        autoload :OddNumberMatcher,   'shoulda/matchers/active_model/numericality_matchers/odd_number_matcher'
        autoload :OnlyIntegerMatcher, 'shoulda/matchers/active_model/numericality_matchers/only_integer_matcher'
      end
    end
  end
end
