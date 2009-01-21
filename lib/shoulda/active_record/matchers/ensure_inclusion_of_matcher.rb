module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      class EnsureInclusionOfMatcher < ValidationMatcher

        def in_range(range)
          @range = range
          @minimum = range.first
          @maximum = range.last
          self
        end

        def with_message(message)
          @expected_message = message
          self
        end

        def description
          "ensure inclusion of #{@attribute} in #{@range.inspect}"
        end

        def matches?(subject)
          super(subject)
          @expected_message ||= :inclusion

          disallows_lower_value && 
            allows_minimum_value &&
            disallows_higher_value &&
            allows_maximum_value
        end

        private

        def disallows_lower_value
          @minimum == 0 || disallows_value_of(@minimum - 1, @expected_message)
        end

        def disallows_higher_value
          disallows_value_of(@maximum + 1, @expected_message)
        end

        def allows_minimum_value
          allows_value_of(@minimum, @expected_message)
        end

        def allows_maximum_value
          allows_value_of(@maximum, @expected_message)
        end
      end

      def ensure_inclusion_of(attr)
        EnsureInclusionOfMatcher.new(attr)
      end

    end
  end
end
