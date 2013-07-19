module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:

      # Ensures that the model cannot be saved if the given attribute is not
      # accepted.
      #
      # Options:
      # * <tt>with_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt>. Regexp or string.  Defaults to the
      #   translation for <tt>:accepted</tt>.
      #
      # Example:
      #   it { should validate_acceptance_of(:eula) }
      #
      def validate_acceptance_of(attr)
        ValidateAcceptanceOfMatcher.new(attr)
      end

      class ValidateAcceptanceOfMatcher < ValidationMatcher # :nodoc:

        def with_message(message)
          if message
            @expected_message = message
          end
          self
        end

        def matches?(subject)
          super(subject)
          @expected_message ||= :accepted
          disallows_value_of(false, @expected_message)
        end

        def description
          "require #{@attribute} to be accepted"
        end
      end
    end
  end
end
