require 'forwardable'

module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      class DisallowValueMatcher # :nodoc:
        extend Forwardable

        def_delegators :allow_matcher, :_after_setting_value

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

        def on(context)
          @allow_matcher.on(context)
          self
        end

        def with_message(message, options={})
          @allow_matcher.with_message(message, options)
          self
        end

        def failure_message
          @allow_matcher.failure_message_when_negated
        end
        alias failure_message_for_should failure_message

        def failure_message_when_negated
          @allow_matcher.failure_message
        end
        alias failure_message_for_should_not failure_message_when_negated

        def strict
          @allow_matcher.strict
          self
        end

        private

        attr_reader :allow_matcher
      end
    end
  end
end
