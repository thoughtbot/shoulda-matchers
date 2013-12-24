module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      module NumericalityMatchers
        class OnlyIntegerMatcher # :nodoc:
          NON_INTEGER_VALUE = 0.1

          def initialize(attribute)
            @attribute = attribute
            @disallow_value_matcher = DisallowValueMatcher.new(NON_INTEGER_VALUE).
              for(attribute).
              with_message(:not_an_integer)
          end

          def matches?(subject)
            @disallow_value_matcher.matches?(subject)
          end

          def with_message(message)
            @disallow_value_matcher.with_message(message)
            self
          end

          def allowed_types
            'integer'
          end

          def failure_message
            @disallow_value_matcher.failure_message
          end
          alias failure_message_for_should failure_message

          def failure_message_when_negated
            @disallow_value_matcher.failure_message_when_negated
          end
          alias failure_message_for_should_not failure_message_when_negated
        end
      end
    end
  end
end
