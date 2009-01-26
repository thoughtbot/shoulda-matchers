module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers

      # Ensure that the belongs_to relationship exists.
      #
      #   it { should belong_to(:parent) }
      #
      def belong_to(name)
        AssociationMatcher.new(:belongs_to, name)
      end

      # Ensures that the has_many relationship exists.  Will also test that the
      # associated table has the required columns.  Works with polymorphic
      # associations.
      #
      # Options:
      # * <tt>through</tt> - association name for <tt>has_many :through</tt>
      # * <tt>dependent</tt> - tests that the association makes use of the
      #   dependent option.
      #
      # Example:
      #   it { should_have_many(:friends) }
      #   it { should_have_many(:enemies).through(:friends) }
      #   it { should_have_many(:enemies).dependent(:destroy) }
      #
      def have_many(name)
        AssociationMatcher.new(:has_many, name)
      end

      # Ensure that the has_one relationship exists.  Will also test that the
      # associated table has the required columns.  Works with polymorphic
      # associations.
      #
      # Options:
      # * <tt>:dependent</tt> - tests that the association makes use of the
      #   dependent option.
      #
      # Example:
      #   it { should have_one(:god) } # unless hindu
      #
      def have_one(name)
        AssociationMatcher.new(:has_one, name)
      end

      # Ensures that the has_and_belongs_to_many relationship exists, and that
      # the join table is in place.
      #
      #   it { should have_and_belong_to_many(:posts) }
      #
      def have_and_belong_to_many(name)
        AssociationMatcher.new(:has_and_belongs_to_many, name)
      end

      class AssociationMatcher # :nodoc:
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
            dependent_correct? &&
            join_table_exists?
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

        def join_table_exists?
          if @macro != :has_and_belongs_to_many || 
              ::ActiveRecord::Base.connection.tables.include?(join_table.to_s)
            true
          else
            @missing = "join table #{join_table} doesn't exist"
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

        def join_table
          reflection.options[:join_table]
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
          when 'has_one'    then 'have one'
          when 'has_and_belongs_to_many' then
            'have and belong to many'
          end
        end
      end

    end
  end
end
