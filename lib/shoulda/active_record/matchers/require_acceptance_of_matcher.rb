module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      class RequireAcceptanceOfMatcher < ValidationMatcher

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

      def require_acceptance_of(attr)
        RequireAcceptanceOfMatcher.
          new(attr)
      end
    end
  end
end
