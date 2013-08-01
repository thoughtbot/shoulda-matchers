module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:

      # Ensures that the model is not valid if the given attribute is
      # present. Work by default with string/text columns.
      #
      # Options:
      # * <tt>with_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt>. <tt>Regexp</tt> or <tt>String</tt>.
      #   Defaults to the translation for <tt>:present</tt>.
      # * <tt>of_type</tt> - db column type (:integer or :string)
      #
      # Examples:
      #   it { should validate_absence_of(:name) }
      #   it { should validate_absence_of(:name).
      #                 with_message(/must be left blank/) }
      #   it { should validate_absence_of(:user_id).
      #                 of_type(:integer) }
      #
      def validate_absence_of(attr)
        ValidateAbsenceOfMatcher.new(attr)
      end

      class ValidateAbsenceOfMatcher < ValidationMatcher # :nodoc:

        def with_message(message)
          @expected_message = message if message
          self
        end

        def of_type(type)
          @type = type if type
        end

        def matches?(subject)
          super(subject)
          @expected_message ||= :present
          @type ||= :string
          disallows_value_of(set_value, @expected_message)
        end

        def description
          "require #{@attribute} not to be set"
        end

        private

        def set_value
          if @type == :string
            'a'
          else
            1
          end
        end
      end
    end
  end
end
