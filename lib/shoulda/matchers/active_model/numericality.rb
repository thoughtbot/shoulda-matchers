module Shoulda
  module Matchers
    module ActiveModel
      # @private
      module Numericality
      end
    end
  end
end

require 'shoulda/matchers/active_model/numericality/numeric_type_matcher'
require 'shoulda/matchers/active_model/numericality/comparison_matcher'
require 'shoulda/matchers/active_model/numericality/odd_number_matcher'
require 'shoulda/matchers/active_model/numericality/even_number_matcher'
require 'shoulda/matchers/active_model/numericality/only_integer_matcher'
