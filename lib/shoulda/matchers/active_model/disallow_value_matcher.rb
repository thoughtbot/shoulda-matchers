require 'forwardable'
module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      class DisallowValueMatcher # :nodoc:
        def initialize(*values)
          @values = values
        end

        def for(attribute)
          @allow_matcher = AllowValueMatcher.new(*@values).for(attribute)
          self
        end

        def matches?(instance)
          ! @allow_matcher.matches?(instance)
        end

        def description
          "not " + @allow_matcher.description
        end

        def failure_message
          @allow_matcher.negative_failure_message
        end

        def negative_failure_message
          @allow_matcher.failure_message
        end
      end
    end
  end
end
