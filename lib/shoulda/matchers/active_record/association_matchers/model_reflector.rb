module Shoulda
  module Matchers
    module ActiveRecord
      module AssociationMatchers
        # @private
        class ModelReflector
          delegate :associated_class, :through?, :join_table_name,
            :association_relation, :polymorphic?, :foreign_key,
            :association_foreign_key, to: :reflection

          def initialize(subject, name)
            @subject = subject
            @name = name
          end

          def reflection
            @reflection ||= reflect_on_association(name)
          end

          def reflect_on_association(name)
            reflection = model_class.reflect_on_association(name)

            if reflection
              ModelReflection.new(reflection)
            end
          end

          def model_class
            subject.class
          end

          def build_relation_with_clause(name, value)
            case name
              when :conditions then associated_class.where(value)
              when :order      then associated_class.order(value)
              else                  raise ArgumentError, "Unknown clause '#{name}'"
            end
          end

          def extract_relation_clause_from(relation, name)
            case name
            when :conditions
              relation.where_values_hash
            when :order
              relation.order_values.map { |value| value_as_sql(value) }.join(', ')
            else
              raise ArgumentError, "Unknown clause '#{name}'"
            end
          end

          protected

          attr_reader :subject, :name

          def value_as_sql(value)
            if value.respond_to?(:to_sql)
              value.to_sql
            else
              value
            end
          end
        end
      end
    end
  end
end
