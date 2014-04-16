module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:

      # Ensures that the model is not valid if the given attribute is not
      # present.
      #
      # Options:
      # * <tt>with_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt>. <tt>Regexp</tt> or <tt>String</tt>.
      #   Defaults to the translation for <tt>:blank</tt>.
      #
      # Examples:
      #   it { should validate_presence_of(:name) }
      #   it { should validate_presence_of(:name).
      #                 with_message(/is not optional/) }
      #
      def validate_presence_of(attr)
        ValidatePresenceOfMatcher.new(attr)
      end

      class ValidatePresenceOfMatcher < ValidationMatcher # :nodoc:
        def with_message(message)
          @expected_message = message if message
          self
        end

        def matches?(subject)
          super(subject)
          @expected_message ||= :blank

          if secure_password_being_validated?
            disallows_and_double_checks_value_of!(blank_value, @expected_message)
          else
            disallows_value_of(blank_value, @expected_message)
          end
        end

        def description
          "require #{@attribute} to be set"
        end

        private

        def secure_password_being_validated?
          defined?(::ActiveModel::SecurePassword) &&
            @subject.class.ancestors.include?(::ActiveModel::SecurePassword::InstanceMethodsOnActivation) &&
            @attribute == :password
        end

        def disallows_and_double_checks_value_of!(value, message)
          error_class = Shoulda::Matchers::ActiveModel::CouldNotSetPasswordError

          disallows_value_of(value, message) do |matcher|
            matcher._after_setting_value do
              actual_value = @subject.__send__(@attribute)

              if !actual_value.nil?
                raise error_class.create(@subject.class)
              end
            end
          end
        end

        def blank_value
          if collection?
            []
          else
            nil
          end
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
