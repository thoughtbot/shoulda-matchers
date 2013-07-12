module Shoulda # :nodoc:
  module Matchers
    module ActiveRecord # :nodoc:
      module AssociationMatchers
        class OptionVerifier
          def initialize(reflector)
            @reflector = reflector
          end

          def correct_for?(option_name, expected_value)
            expected_value.nil? || expected_value == actual_value_for(option_name)
          end

          def correct_for_string?(option_name, expected_value)
            expected_value.nil? || expected_value.to_s == actual_value_for(option_name).to_s
          end

          def correct_for_boolean?(option_name, expected_value)
            expected_value.nil? || !!expected_value == !!actual_value_for(option_name)
          end

          def actual_value_for(option_name)
            method_name = "actual_value_for_#{option_name}"
            if respond_to?(method_name, true)
              __send__(method_name)
            else
              default_actual_value_for(option_name)
            end
          end

          private

          def default_actual_value_for(option_name)
            reflection.options[option_name]
          end

          def actual_value_for_class_name
            reflector.associated_class
          end

          def actual_value_for_conditions
            reflector.where_conditions
          end

          def reflection
            reflector.reflection
          end

          attr_reader :reflector
        end
      end
    end
  end
end
