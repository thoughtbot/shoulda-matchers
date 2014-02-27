module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      module NumericalityMatchers
        class NumericTypeMatcher
          def initialize
            raise NotImplementedError
          end

          def matches?(subject)
            @disallow_value_matcher.matches?(subject)
          end

          def with_message(message)
            @disallow_value_matcher.with_message(message)
            self
          end

          def allowed_type
            raise NotImplementedError
          end

          def diff_to_compare
            raise NotImplementedError
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
