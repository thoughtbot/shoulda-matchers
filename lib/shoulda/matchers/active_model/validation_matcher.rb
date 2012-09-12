module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      class ValidationMatcher # :nodoc:
        attr_reader :failure_message

        def initialize(attribute)
          @attribute = attribute
          @strict = false
        end

        def strict
          @strict = true
          self
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
          if strict?
            allow = allow.strict
          end
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
          if strict?
            disallow = disallow.strict
          end
          if disallow.matches?(@subject)
            @failure_message = disallow.negative_failure_message
            false
          else
            @negative_failure_message = disallow.failure_message
            true
          end
        end

        def strict?
          @strict
        end
      end
    end
  end
end
