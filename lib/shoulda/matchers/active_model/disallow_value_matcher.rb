module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      class DisallowValueMatcher # :nodoc:
        def initialize(value)
          @allow_matcher = AllowValueMatcher.new(value)
        end

        def matches?(subject)
          !@allow_matcher.matches?(subject)
        end

        def for(attribute)
          @allow_matcher.for(attribute)
          self
        end

        def with_message(message)
          @allow_matcher.with_message(message)
          self
        end

        def failure_message_for_should
          @allow_matcher.failure_message_for_should_not
        end

        def failure_message_for_should_not
          @allow_matcher.failure_message_for_should
        end

        def allowed_types
          ''
        end

        def strict
          @allow_matcher.strict
          self
        end
      end
    end
  end
end
