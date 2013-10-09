module Shoulda
  module Matchers
    module ActiveModel
      # @private
      module Uniqueness
      end
    end
  end
end

require 'shoulda/matchers/active_model/uniqueness/model'
require 'shoulda/matchers/active_model/uniqueness/namespace'
require 'shoulda/matchers/active_model/uniqueness/test_model_creator'
require 'shoulda/matchers/active_model/uniqueness/test_models'
