module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      class EnsureLengthOfMatcher
        include Helpers

        def initialize(attribute)
          @attribute = attribute
        end

        def is_at_least(length)
          @minimum = length
          @short_message ||= :too_short
          if Symbol === @short_message
            @short_message = default_error_message(@short_message,
                                                      :count => @minimum)
          end
          self
        end

        def with_short_message(message)
          @short_message = message if message
          self
        end

        attr_reader :failure_message, :negative_failure_message

        def description
          "ensure #{@attribute} has a length of at least #{@minimum}"
        end

        def matches?(subject)
          @subject = subject
          disallows_lower_length && allows_correct_length
        end

        private

        def disallows_lower_length
          return true if @minimum == 0
          @disallow = AllowValueMatcher.
            new(value_of_length(@minimum - 1)).
            for(@attribute).
            with_message(@short_message)
          if @disallow.matches?(@subject)
            @failure_message = @disallow.negative_failure_message
            false
          else
            @negative_failure_message = @disallow.failure_message
            true
          end
        end

        def allows_correct_length
          @allow = AllowValueMatcher.
            new(value_of_length(@minimum)).
            for(@attribute).
            with_message(@short_message)
          if @allow.matches?(@subject)
            @negative_failure_message = @allow.failure_message
            true
          else
            @failure_message = @allow.negative_failure_message
            false
          end
        end

        def value_of_length(length)
          'x' * length
        end
      end

      def ensure_length_of(attr)
        EnsureLengthOfMatcher.new(attr)
      end

    end
  end
end
