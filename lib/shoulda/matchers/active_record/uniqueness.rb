module Shoulda
  module Matchers
    module ActiveModel
      # @private
      module Uniqueness
      end
    end
  end
end

require 'shoulda/matchers/active_record/uniqueness/model'
require 'shoulda/matchers/active_record/uniqueness/namespace'
require 'shoulda/matchers/active_record/uniqueness/test_model_creator'
require 'shoulda/matchers/active_record/uniqueness/test_models'
