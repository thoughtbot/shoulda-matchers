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

          def where_conditions
            RailsShim.association_conditions(reflection)
          end

          private

          attr_reader :subject, :name
        end
      end
    end
  end
end
