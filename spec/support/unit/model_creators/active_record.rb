require_relative '../model_creators'
require 'forwardable'

module UnitTests
  module ModelCreators
    class ActiveRecord
      def self.call(args)
        new(args).call
      end

      extend Forwardable

      def_delegators(
        :arguments,
        :attribute_default_values_by_name,
        :attribute_name,
        :customize_model,
        :model_name,
      )

      def_delegators :model_creator, :customize_model

      def initialize(args)
        @arguments = CreateModelArguments::Basic.wrap(
          args.merge(
            model_creation_strategy: UnitTests::ModelCreationStrategies::ActiveRecord
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

    register(:active_record, ActiveRecord)
  end
end
