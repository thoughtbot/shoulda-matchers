module Shoulda # :nodoc:
  module Matchers
    module ActiveRecord # :nodoc:
      module AssociationMatchers
        class ModelReflector
          def initialize(subject, name)
            @subject = subject
            @name = name
          end

          def reflection
            @reflection ||= reflect_on_association(name)
          end

          def reflect_on_association(name)
            model_class.reflect_on_association(name)
          end

          def model_class
            subject.class
          end

          def associated_class
            reflection.klass
          end

          def through?
            reflection.options[:through]
          end

          def join_table
            if reflection.respond_to? :join_table
              reflection.join_table.to_s
            else
              reflection.options[:join_table].to_s
            end
          end

          def association_relation
            if reflection.respond_to?(:scope) && reflection.scope
              relation_from_scope(reflection.scope)
            else
              options = reflection.options
              relation = RailsShim.clean_scope(reflection.klass)
              if options[:conditions]
                relation = relation.where(options[:conditions])
              end
              if options[:include]
                relation = relation.include(options[:include])
              end
              if options[:order]
                relation = relation.order(options[:order])
              end
              if options[:group]
                relation = relation.group(options[:group])
              end
              if options[:having]
                relation = relation.having(options[:having])
              end
              if options[:limit]
                relation = relation.limit(options[:limit])
              end
              relation
            end
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
              when :conditions then relation.where_values_hash
              when :order      then relation.order_values.join(', ')
              else                  raise ArgumentError, "Unknown clause '#{name}'"
            end
          end

          private

          def relation_from_scope(scope)
            # Source: AR::Associations::AssociationScope#eval_scope
            if scope.is_a?(::Proc)
              associated_class.all.instance_exec(subject, &scope)
            else
              scope
            end
          end

          attr_reader :subject, :name
        end
      end
    end
  end
end
