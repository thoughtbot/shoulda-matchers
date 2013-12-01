module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      class OddEvenNumberMatcher # :nodoc:
        NON_EVEN_NUMBER_VALUE = 1
        NON_ODD_NUMBER_VALUE  = 2

        def initialize(attribute, options = {})
          @attribute = attribute
          options[:odd]   ||= true
          options[:even]  ||= false

          if options[:odd] && !options[:even]
            @disallow_value_matcher =
              DisallowValueMatcher.new(@attribute, NON_ODD_NUMBER_VALUE).
              with_message(:odd)
          else
            @disallow_value_matcher =
              DisallowValueMatcher.new(@attribute, NON_EVEN_NUMBER_VALUE).
              with_message(:even)
          end
        end

        def matches?(subject)
          @disallow_value_matcher.matches?(subject)
        end

        def with_message(message)
          @disallow_value_matcher.with_message(message)
          self
        end

        def allowed_types
          'integer'
        end

        def failure_message_for_should
          @disallow_value_matcher.failure_message_for_should
        end

        def failure_message_for_should_not
          @disallow_value_matcher.failure_message_for_should_not
        end
      end
    end
  end
end
