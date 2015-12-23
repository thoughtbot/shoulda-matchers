require_relative '../../model_creators'
require 'forwardable'

module UnitTests
  module ModelCreators
    class ActiveRecord
      class UniquenessMatcher
        def self.call(args)
          new(args).call
        end

        extend Forwardable

        def_delegators(
          :arguments,
          :attribute_name,
          :attribute_default_values_by_name,
        )

        def initialize(args)
          @arguments = CreateModelArguments::UniquenessMatcher.wrap(args)
          @model_creator = UnitTests::ModelCreators::ActiveRecord.new(
            arguments
          )
        end

        def call
          model_creator.call
        end

        protected

        attr_reader :arguments, :model_creator
      end
    end

    register(
      :"active_record/uniqueness_matcher",
      ActiveRecord::UniquenessMatcher
    )
  end
end
