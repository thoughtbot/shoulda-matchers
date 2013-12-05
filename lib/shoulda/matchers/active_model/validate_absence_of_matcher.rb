module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:

      # Ensures that the model is not valid if the given attribute is present.
      #
      # Options:
      # * <tt>with_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt>. <tt>Regexp</tt> or <tt>String</tt>.
      #   Defaults to the translation for <tt>:present</tt>.
      #
      # Examples:
      #   it { should validate_absence_of(:name) }
      #   it { should validate_absence_of(:name).
      #                 with_message(/is not included in list/) }
      #
      # Pre-Rails 4:
      # If you are not using Rails 4 and are testing for absence using a custom
      # or inclusion validation, you can still use validate_absence_of to test
      # it. Either set the message of the validation to <tt>:present</tt> or use
      # <tt>with_message</tt> to change the message that validate_absence_of
      # checks for.
      def validate_absence_of(attr)
        ValidateAbsenceOfMatcher.new(attr)
      end

      class ValidateAbsenceOfMatcher < ValidationMatcher # :nodoc:

        def with_message(message)
          @expected_message = message
          self
        end

        def matches?(subject)
          super(subject)
          @expected_message ||= :present
          disallows_value_of(value, @expected_message)
        end

        def description
          "require #{@attribute} to not be set"
        end

        private

        def value
          if reflection
            obj = reflection.klass.new
            if collection?
              [ obj ]
            else
              obj
            end
          elsif attribute_class == Fixnum
            1
          elsif !attribute_class || attribute_class == String
            'HEY-OH!'
          else
            attribute_class.new
          end
        end

        def attribute_class
          @subject.class.respond_to?(:columns_hash) &&
            @subject.class.columns_hash[@attribute].respond_to?(:klass) &&
            @subject.class.columns_hash[@attribute].klass
        end

        def collection?
          if reflection
            [:has_many, :has_and_belongs_to_many].include?(reflection.macro)
          else
            false
          end
        end

        def reflection
          @subject.class.respond_to?(:reflect_on_association) &&
            @subject.class.reflect_on_association(@attribute)
        end
      end
    end
  end
end
