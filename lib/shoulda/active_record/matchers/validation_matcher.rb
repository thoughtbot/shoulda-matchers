module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers

      class ValidationMatcher # :nodoc:

        attr_reader :failure_message

        def initialize(attribute)
          @attribute = attribute
        end

        def negative_failure_message
          @negative_failure_message || @failure_message
        end

        def matches?(subject)
          @subject = subject
          false
        end

        private

        def allows_value_of(value, message = nil)
          allow = AllowValueMatcher.
            new(value).
            for(@attribute).
            with_message(message)
          if allow.matches?(@subject)
            @negative_failure_message = allow.failure_message
            true
          else
            @failure_message = allow.negative_failure_message
            false
          end
        end

        def disallows_value_of(value, message = nil)
          disallow = AllowValueMatcher.
            new(value).
            for(@attribute).
            with_message(message)
          if disallow.matches?(@subject)
            @failure_message = disallow.negative_failure_message
            false
          else
            @negative_failure_message = disallow.failure_message
            true
          end
        end
      end

    end
  end
end

