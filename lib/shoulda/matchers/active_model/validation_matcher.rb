module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      class ValidationMatcher # :nodoc:
        attr_reader :failure_message_for_should

        def initialize(attribute)
          @attribute = attribute
          @strict = false
        end

        def on(context)
          @context = context
          self
        end

        def strict
          @strict = true
          self
        end

        def failure_message_for_should_not
          @failure_message_for_should_not || @failure_message_for_should
        end

        def matches?(subject)
          @subject = subject
          false
        end

        private

        def allows_value_of(value, message = nil)
          allow = allow_value_matcher(value, message)

          if allow.matches?(@subject)
            @failure_message_for_should_not = allow.failure_message_for_should_not
            true
          else
            @failure_message_for_should = allow.failure_message_for_should
            false
          end
        end

        def disallows_value_of(value, message = nil)
          disallow = disallow_value_matcher(value, message)

          if disallow.matches?(@subject)
            @failure_message_for_should_not = disallow.failure_message_for_should_not
            true
          else
            @failure_message_for_should = disallow.failure_message_for_should
            false
          end
        end

        def allow_value_matcher(value, message)
          matcher = AllowValueMatcher.
            new(value).
            for(@attribute).
            with_message(message)

          if strict?
            matcher.strict
          else
            matcher
          end
        end

        def disallow_value_matcher(value, message)
          matcher = DisallowValueMatcher.
            new(value).
            for(@attribute).
            with_message(message)

          if strict?
            matcher.strict
          else
            matcher
          end
        end

        def strict?
          @strict
        end
      end
    end
  end
end
