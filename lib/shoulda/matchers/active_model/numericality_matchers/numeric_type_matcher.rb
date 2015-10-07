require 'forwardable'

module Shoulda
  module Matchers
    module ActiveModel
      module NumericalityMatchers
        # @private
        class NumericTypeMatcher
          extend Forwardable

          def_delegators :disallow_value_matcher, :matches?, :failure_message,
            :failure_message_when_negated

          def initialize(numeric_type_matcher, attribute, options = {})
            @numeric_type_matcher = numeric_type_matcher
            @attribute = attribute
            @options = options
            @message = nil
            @context = nil
            @strict = false
          end

          def with_message(message)
            @message = message
            self
          end

          def strict
            @strict = true
            self
          end

          def on(context)
            @context = context
            self
          end

          def allowed_type
            raise NotImplementedError
          end

          def diff_to_compare
            raise NotImplementedError
          end

          protected

          attr_reader :attribute

          def wrap_disallow_value_matcher(matcher)
            raise NotImplementedError
          end

          def disallowed_value
            raise NotImplementedError
          end

          private

          def disallow_value_matcher
            @_disallow_value_matcher ||= begin
              DisallowValueMatcher.new(disallowed_value).tap do |matcher|
                matcher.for(attribute)
                wrap_disallow_value_matcher(matcher)

                if @message
                  matcher.with_message(@message)
                end

                if @strict
                  matcher.strict
                end

                if @context
                  matcher.on(@context)
                end
              end
            end
          end
        end
      end
    end
  end
end
