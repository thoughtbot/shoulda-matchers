require 'forwardable'

module Shoulda
  module Matchers
    module ActiveModel
      # @private
      class DisallowValueMatcher
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

        def ignoring_interference_by_writer
          @allow_matcher.ignoring_interference_by_writer
          self
        end

        def failure_message
          @allow_matcher.failure_message_when_negated
        end

        def failure_message_when_negated
          @allow_matcher.failure_message
        end

        def strict
          @allow_matcher.strict
          self
        end

        protected

        attr_reader :allow_matcher
      end
    end
  end
end
