module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      class EnsureInclusionOfMatcher
        include Helpers

        def initialize(attribute)
          @attribute = attribute
        end

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

        attr_reader :failure_message, :negative_failure_message

        def description
          "ensure inclusion of #{@attribute} in #{@range.inspect}"
        end

        def matches?(subject)
          @subject = subject
          @expected_message ||= :inclusion
          if Symbol === @expected_message
            @expected_message = default_error_message(@expected_message)
          end

          disallows_lower_value && 
            allows_minimum_value &&
            disallows_higher_value &&
            allows_maximum_value
        end

        private

        def disallows_lower_value
          return true if @minimum == 0
          disallows_value_of(@minimum - 1)
        end

        def disallows_higher_value
          disallows_value_of(@maximum + 1)
        end

        def allows_minimum_value
          allows_value_of(@minimum)
        end

        def allows_maximum_value
          allows_value_of(@maximum)
        end

        def allows_value_of(value)
          @allow = AllowValueMatcher.
            new(value).
            for(@attribute).
            with_message(@expected_message)
          if @allow.matches?(@subject)
            @negative_failure_message = @allow.failure_message
            true
          else
            @failure_message = @allow.negative_failure_message
            false
          end
        end

        def disallows_value_of(value)
          @disallow = AllowValueMatcher.
            new(value).
            for(@attribute).
            with_message(@expected_message)
          if @disallow.matches?(@subject)
            @failure_message = @disallow.negative_failure_message
            false
          else
            @negative_failure_message = @disallow.failure_message
            true
          end
        end
      end

      def ensure_inclusion_of(attr)
        EnsureInclusionOfMatcher.new(attr)
      end

    end
  end
end
