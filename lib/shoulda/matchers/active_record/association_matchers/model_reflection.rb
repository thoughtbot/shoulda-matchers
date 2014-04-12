require 'delegate'

module Shoulda
  module Matchers
    module ActiveRecord
      module AssociationMatchers
        class ModelReflection < SimpleDelegator
          def initialize(reflection)
            super(reflection)
            @reflection = reflection
            @subject = reflection.active_record
          end

          def associated_class
            reflection.klass
          end

          def polymorphic?
            reflection.options[:polymorphic]
          end

          def through?
            reflection.options[:through]
          end

          def join_table
            join_table =
              if has_and_belongs_to_many_name_table_name
                has_and_belongs_to_many_name_table_name
              elsif reflection.respond_to?(:join_table)
                reflection.join_table
              else
                reflection.options[:join_table]
              end

            join_table.to_s
          end

          def association_relation
            if reflection.respond_to?(:scope)
              convert_scope_to_relation(reflection.scope)
            else
              convert_options_to_relation(reflection.options)
            end
          end

          private

          attr_reader :reflection, :subject

          def convert_scope_to_relation(scope)
            relation = associated_class.all

            if scope
              # Source: AR::Associations::AssociationScope#eval_scope
              relation.instance_exec(subject, &scope)
            else
              relation
            end
          end

          def convert_options_to_relation(options)
            relation = associated_class.scoped
            relation = extend_relation_with(relation, :where, options[:conditions])
            relation = extend_relation_with(relation, :includes, options[:include])
            relation = extend_relation_with(relation, :order, options[:order])
            relation = extend_relation_with(relation, :group, options[:group])
            relation = extend_relation_with(relation, :having, options[:having])
            relation = extend_relation_with(relation, :limit, options[:limit])
            relation = extend_relation_with(relation, :offset, options[:offset])
            relation = extend_relation_with(relation, :select, options[:select])
            relation
          end

          def extend_relation_with(relation, method_name, value)
            if value
              relation.__send__(method_name, value)
            else
              relation
            end
          end

          def has_and_belongs_to_many_name
            reflection.options[:through]
          end

          def has_and_belongs_to_many_name_table_name
            if has_and_belongs_to_many_reflection
              has_and_belongs_to_many_reflection.table_name
            end
          end

          def has_and_belongs_to_many_reflection
            @_has_and_belongs_to_many_reflection ||=
              if has_and_belongs_to_many_name
                @subject.reflect_on_association(has_and_belongs_to_many_name)
              end
          end
        end
      end
    end
  end
end
