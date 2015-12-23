require_relative '../model_creators'
require 'forwardable'

module UnitTests
  module ModelCreators
    class ActiveModel
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
        @arguments = CreateModelArguments::Basic.wrap(
          args.merge(
            model_creation_strategy: UnitTests::ModelCreationStrategies::ActiveModel
          )
        )
        @model_creator = Basic.new(arguments)
      end

      def call
        model_creator.call
      end

      protected

      attr_reader :arguments, :model_creator
    end

    register(:active_model, ActiveModel)
  end
end
