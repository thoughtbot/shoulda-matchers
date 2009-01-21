module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      class OnlyAllowNumericValuesMatcher < ValidationMatcher

        def with_message(message)
          @expected_message = message if message
          self
        end

        def matches?(subject)
          super(subject)
          @expected_message ||= :not_a_number
          disallows_value_of('abcd', @expected_message)
        end

        def description
          "only allow numeric values for #{@attribute}"
        end
      end

      def only_allow_numeric_values_for(attr)
        OnlyAllowNumericValuesMatcher.new(attr)
      end
    end
  end
end
