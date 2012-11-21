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

        def failure_message
          @allow_matcher.negative_failure_message
        end

        def allowed_types
          ""
        end
      end
    end
  end
end
