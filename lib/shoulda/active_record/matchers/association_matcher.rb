module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      class AssociationMatcher
        def initialize(macro, name)
          @macro = macro
          @name  = name
        end

        def matches?(subject)
          @subject = subject
          association_exists? && macro_correct? && foreign_key_exists?
        end

        def failure_message
          "Expected #{expectation} (#{@missing})"
        end

        def negative_failure_message
          "Did not expect #{expectation}"
        end

        protected

        def association_exists?
          if reflection.nil?
            @missing = "no association called #{@name}"
            false
          else
            true
          end
        end

        def macro_correct?
          if reflection.macro == @macro
            true
          else
            @missing = "actual association type was #{reflection.macro}"
            false
          end
        end

        def foreign_key_exists?
          if model_class.column_names.include?(foreign_key.to_s)
            true
          else
            @missing = "#{model_class.name} does not have a #{foreign_key} foreign key."
            false
          end
        end

        def model_class
          @subject.class
        end

        def foreign_key
          reflection.primary_key_name
        end

        def reflection
          @reflection ||= model_class.reflect_on_association(@name)
        end

        def expectation
          "#{model_class.name} to have a #{@macro} association called #{@name}"
        end
      end

      def belong_to(name)
        AssociationMatcher.new(:belongs_to, name)
      end

    end
  end
end
