module Shoulda # :nodoc:
  module Matchers
    module ActiveRecord # :nodoc:
      module AssociationMatchers
        class OptionVerifier
          delegate :reflection, to: :reflector

          attr_reader :reflector

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

          def actual_value_for(name)
            method_name = "actual_value_for_#{name}"
            if respond_to?(method_name, true)
              __send__(method_name)
            else
              reflection.options[name]
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
              when :string  then value.to_s
              when :boolean then !!value
              when :hash    then Hash(value).stringify_keys
              else               value
            end
          end

          def expected_value_for(name, value)
            value
          end

          def actual_value_for_class_name
            reflector.associated_class
          end
        end
      end
    end
  end
end
