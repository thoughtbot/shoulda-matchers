require 'forwardable'
module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      class DisallowValueMatcher # :nodoc:
        extend Forwardable
        def_delegators :@allow_matcher, :with_message, :failure_message,
          :negative_failure_message, :description

        def initialize(*values)
          @values = values
        end

        def for(attribute)
          @allow_matcher = AllowValueMatcher.new(@values).for(attribute)
          self
        end

        def matches?(instance)
          ! @allow_matcher.matches?(instance)
        end
      end
    end
  end
end
