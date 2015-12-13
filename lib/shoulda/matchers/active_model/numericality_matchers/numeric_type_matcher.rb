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
            @expects_strict = false
            @expects_custom_validation_message = false
          end

          def with_message(message)
            if message
              @expects_custom_validation_message = true
              @message = message
            end

            self
          end

          def expects_custom_validation_message?
            @expects_custom_validation_message
          end

          def strict
            @expects_strict = true
            self
          end

          def expects_strict?
            @expects_strict
          end

          def on(context)
            @context = context
            self
          end

          def allowed_type_name
            'number'
          end

          def allowed_type_adjective
            ''
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

                if expects_strict?
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
