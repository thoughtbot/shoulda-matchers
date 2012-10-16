module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      class OnlyIntegerMatcher # :nodoc:
        def initialize(attribute)
          @attribute = attribute
        end

        def matches?(subject)
          matcher = AllowValueMatcher.new(0.1).for(@attribute)
          !matcher.matches?(subject)
        end

        def with_message(message)
          self
        end

        def allowed_types
          "integer"
        end
      end
    end
  end
end
