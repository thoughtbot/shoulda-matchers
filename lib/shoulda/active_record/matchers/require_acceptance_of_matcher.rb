module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers

      # Ensures that the model cannot be saved the given attribute is not
      # accepted.
      #
      # Options:
      # * <tt>with_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt>. Regexp or string.  Defaults to the
      #   translation for <tt>:accepted</tt>.
      #
      # Example:
      #   it { should require_acceptance_of(:eula) }
      #
      def require_acceptance_of(attr)
        RequireAcceptanceOfMatcher.
          new(attr)
      end

      class RequireAcceptanceOfMatcher < ValidationMatcher # :nodoc:

        def with_message(message)
          @expected_message = message if message
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
