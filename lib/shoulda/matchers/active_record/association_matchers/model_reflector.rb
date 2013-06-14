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

          def option_string(key)
            reflection.options[key].to_s
          end

          def option_set_properly?(option, option_key)
            option.to_s == option_string(option_key)
          end

          private
          attr_reader :subject, :name
        end
      end
    end
  end
end
