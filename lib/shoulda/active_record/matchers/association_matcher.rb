module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      class AssociationMatcher
        def initialize(macro, name)
          @macro = macro
          @name  = name
        end

        def through(through)
          @through = through
          self
        end

        def dependent(dependent)
          @dependent = dependent
          self
        end

        def matches?(subject)
          @subject = subject
          association_exists? && 
            macro_correct? && 
            foreign_key_exists? && 
            through_association_valid? && 
            dependent_correct?
        end

        def failure_message
          "Expected #{expectation} (#{@missing})"
        end

        def negative_failure_message
          "Did not expect #{expectation}"
        end

        def description
          description = "#{macro_description} #{@name}"
          description += " through #{@through}" if @through
          description += " dependent => #{@dependent}" if @dependent
          description
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
          !(belongs_foreign_key_missing? || has_foreign_key_missing?)
        end

        def belongs_foreign_key_missing?
          @macro == :belongs_to && !class_has_foreign_key?(model_class)
        end

        def has_foreign_key_missing?
          [:has_many, :has_one].include?(@macro) &&
            !through? &&
            !class_has_foreign_key?(associated_class)
        end

        def through_association_valid?
          @through.nil? || (through_association_exists? && through_association_correct?)
        end

        def through_association_exists?
          if through_reflection.nil?
            "#{model_class.name} does not have any relationship to #{@through}"
            false
          else
            true
          end
        end

        def through_association_correct?
          if @through == reflection.options[:through]
            "Expected #{model_class.name} to have #{@name} through #{@through}, " <<
              " but got it through #{reflection.options[:through]}"
            true
          else
            false
          end
        end

        def dependent_correct?
          if @dependent.nil? || @dependent.to_s == reflection.options[:dependent].to_s
            true
          else
            @missing = "#{@name} should have #{@dependent} dependency"
            false
          end
        end

        def class_has_foreign_key?(klass)
          if klass.column_names.include?(foreign_key.to_s)
            true
          else
            @missing = "#{klass} does not have a #{foreign_key} foreign key."
            false
          end
        end

        def model_class
          @subject.class
        end

        def associated_class
          reflection.klass
        end

        def foreign_key
          reflection.primary_key_name
        end

        def through?
          reflection.options[:through]
        end

        def reflection
          @reflection ||= model_class.reflect_on_association(@name)
        end

        def through_reflection
          @through_reflection ||= model_class.reflect_on_association(@through)
        end

        def expectation
          "#{model_class.name} to have a #{@macro} association called #{@name}"
        end

        def macro_description
          case @macro.to_s
          when 'belongs_to' then 'belong to'
          when 'has_many'   then 'have many'
          when 'has_one'    then 'has one'
          end
        end
      end

      def belong_to(name)
        AssociationMatcher.new(:belongs_to, name)
      end

      def have_many(name)
        AssociationMatcher.new(:has_many, name)
      end

      def have_one(name)
        AssociationMatcher.new(:has_one, name)
      end

    end
  end
end
