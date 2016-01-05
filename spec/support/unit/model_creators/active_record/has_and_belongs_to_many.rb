require_relative '../../model_creators'
require 'forwardable'

module UnitTests
  module ModelCreators
    class ActiveRecord
      class HasAndBelongsToMany
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
          parent_child_table_creator.call
          child_model_creator.call
          parent_model_creator.call
        end

        protected

        attr_reader :arguments

        private

        alias_method :association_name, :attribute_name
        alias_method :parent_model_creator_arguments, :arguments

        def parent_child_table_creator
          @_parent_child_table_creator ||=
            UnitTests::ActiveRecord::CreateTable.new(
              parent_child_table_name,
              foreign_key_for_child_model => :integer,
              foreign_key_for_parent_model => :integer,
              :id => false
            )
        end

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

            # TODO: doesn't this need to be a has_many :through?
            model_creator.customize_model do |model|
              model.has_many(association_name)
            end

            model_creator
          end
        end

        def foreign_key_for_child_model
          child_model_name.foreign_key
        end

        def foreign_key_for_parent_model
          parent_model_name.foreign_key
        end

        def parent_child_table_name
          "#{child_model_name.pluralize}#{parent_model_name}".tableize
        end

        def parent_model_name
          parent_model_creator.model_name
        end

        def child_model_name
          association_name.to_s.classify
        end
      end
    end

    register(:"active_record/habtm", ActiveRecord::HasAndBelongsToMany)
  end
end
