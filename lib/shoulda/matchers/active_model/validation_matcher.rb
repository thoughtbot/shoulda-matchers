module Shoulda
  module Matchers
    module ActiveModel
      # @private
      class ValidationMatcher
        attr_reader :failure_message

        def initialize(attribute)
          @attribute = attribute
          @strict = false
          @failure_message = nil
          @failure_message_when_negated = nil
          @allowed_value_conversions = {}
        end

        def on(context)
          @context = context
          self
        end

        def strict
          @strict = true
          self
        end

        def failure_message_when_negated
          @failure_message_when_negated || @failure_message
        end

        def matches?(subject)
          @subject = subject
          false
        end

        def converting_values(value_conversions)
          @allowed_value_conversions.merge!(value_conversions)
          self
        end

        private

        def allows_value_of(value, message = nil, &block)
          allow = allow_value_matcher(value, message)

          yield allow if block_given?

          if allow.matches?(@subject)
            @failure_message_when_negated = allow.failure_message_when_negated
            true
          else
            @failure_message = allow.failure_message
            false
          end
        end

        def disallows_value_of(value, message = nil, &block)
          disallow = disallow_value_matcher(value, message)

          yield disallow if block_given?

          if disallow.matches?(@subject)
            @failure_message_when_negated = disallow.failure_message_when_negated
            true
          else
            @failure_message = disallow.failure_message
            false
          end
        end

        def allow_value_matcher(value, message)
          matcher = AllowValueMatcher.new(value).for(@attribute).
            with_message(message)

          if defined?(@context)
            matcher.on(@context)
          end

          if strict?
            matcher.strict
          end

          unless @allowed_value_conversions.empty?
            matcher.converting_values(@allowed_value_conversions)
          end

          matcher
        end

        def disallow_value_matcher(value, message)
          matcher = DisallowValueMatcher.new(value).for(@attribute).
            with_message(message)

          if defined?(@context)
            matcher.on(@context)
          end

          if strict?
            matcher.strict
          end

          unless @allowed_value_conversions.empty?
            matcher.converting_values(@allowed_value_conversions)
          end

          matcher
        end

        def strict?
          @strict
        end
      end
    end
  end
end
