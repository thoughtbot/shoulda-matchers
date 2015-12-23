require_relative '../../model_creators'
require 'forwardable'

module UnitTests
  module ModelCreators
    class ActiveRecord
      class HasMany
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
          @arguments = CreateModelArguments::HasMany.wrap(args)
        end

        def call
          child_model_creator.call
          parent_model_creator.call
        end

        protected

        attr_reader :arguments

        private

        alias_method :association_name, :attribute_name
        alias_method :parent_model_creator_arguments, :arguments

        def child_model_creator
          @_child_model_creator ||=
            UnitTests::ModelCreationStrategies::ActiveRecord.new(
              child_model_name
            )
        end

        def parent_model_creator
          @_parent_model_creator ||= begin
            model_creator = UnitTests::ModelCreators::ActiveRecord.new(
              parent_model_creator_arguments
            )

            model_creator.customize_model do |model|
              model.has_many(association_name)
            end

            model_creator
          end
        end

        def child_model_name
          association_name.to_s.classify
        end
      end
    end

    register(:"active_record/has_many", ActiveRecord::HasMany)
  end
end
