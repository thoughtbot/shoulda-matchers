module Shoulda # :nodoc:
  module Matchers
    module ActiveRecord # :nodoc:
      module AssociationMatchers
        class OptionVerifier
          delegate :reflection, to: :reflector

          attr_reader :reflector

          RELATION_OPTIONS = [:conditions, :order]

          def initialize(reflector)
            @reflector = reflector
          end

          def correct_for_string?(name, expected_value)
            correct_for?(:string, name, expected_value)
          end

          def correct_for_boolean?(name, expected_value)
            correct_for?(:boolean, name, expected_value)
          end

          def correct_for_hash?(name, expected_value)
            correct_for?(:hash, name, expected_value)
          end

          def correct_for_relation_clause?(name, expected_value)
            correct_for?(:relation_clause, name, expected_value)
          end

          def actual_value_for(name)
            if RELATION_OPTIONS.include?(name)
              actual_value_for_relation_clause(name)
            else
              method_name = "actual_value_for_#{name}"
              if respond_to?(method_name, true)
                __send__(method_name)
              else
                reflection.options[name]
              end
            end
          end

          private

          attr_reader :reflector

          def correct_for?(*args)
            expected_value, name, type = args.reverse
            if expected_value.nil?
              true
            else
              expected_value = type_cast(type, expected_value_for(name, expected_value))
              actual_value = type_cast(type, actual_value_for(name))
              expected_value == actual_value
            end
          end

          def type_cast(type, value)
            case type
              when :string, :relation_clause then value.to_s
              when :boolean                  then !!value
              when :hash                     then Hash(value).stringify_keys
              else                                value
            end
          end

          def expected_value_for(name, value)
            if RELATION_OPTIONS.include?(name)
              expected_value_for_relation_clause(name, value)
            else
              value
            end
          end

          def expected_value_for_relation_clause(name, value)
            relation = reflector.build_relation_with_clause(name, value)
            reflector.extract_relation_clause_from(relation, name)
          end

          def actual_value_for_relation_clause(name)
            reflector.extract_relation_clause_from(reflector.association_relation, name)
          end

          def actual_value_for_class_name
            reflector.associated_class
          end
        end
      end
    end
  end
end
