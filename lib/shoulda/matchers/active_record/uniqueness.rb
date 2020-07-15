module Shoulda
  module Matchers
    module ActiveRecord
      # @private
      module Uniqueness
        autoload :Model, 'shoulda/matchers/active_record/uniqueness/model'
        autoload :Namespace, 'shoulda/matchers/active_record/uniqueness/namespace'
        autoload :TestModelCreator, 'shoulda/matchers/active_record/uniqueness/test_model_creator'
        autoload :TestModels, 'shoulda/matchers/active_record/uniqueness/test_models'
      end
    end
  end
end

