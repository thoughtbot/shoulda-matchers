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
          self
        end

        def is_at_most(length)
          @maximum = length
          @long_message ||= :too_long
          self
        end

        def is_equal_to(length)
          @minimum = length
          @maximum = length
          @short_message ||= :wrong_length
          self
        end

        def with_short_message(message)
          @short_message = message if message
          self
        end
        alias_method :with_message, :with_short_message

        def with_long_message(message)
          @long_message = message if message
          self
        end

        attr_reader :failure_message, :negative_failure_message

        def description
          description =  "ensure #{@attribute} has a length "
          if @minimum && @maximum
            if @minimum == @maximum
              description << "of exactly #{@minimum}"
            else
              description << "between #{@minimum} and #{@maximum}"
            end
          else
            description << "of at least #{@minimum}" if @minimum
            description << "of at most #{@maximum}" if @maximum
          end
          description
        end

        def matches?(subject)
          @subject = subject
          translate_messages!
          disallows_lower_length && 
            allows_minimum_length &&
            ((@minimum == @maximum) ||
              (disallows_higher_length &&
              allows_maximum_length))
        end

        private

        def translate_messages!
          if Symbol === @short_message
            @short_message = default_error_message(@short_message,
                                                   :count => @minimum)
          end

          if Symbol === @long_message
            @long_message = default_error_message(@long_message,
                                                  :count => @maximum)
          end
        end

        def disallows_lower_length
          return true if @minimum == 0 || @minimum.nil?
          disallows_length_of(@minimum - 1, @short_message)
        end

        def disallows_higher_length
          return true if @maximum.nil?
          disallows_length_of(@maximum + 1, @long_message)
        end

        def allows_minimum_length
          allows_length_of(@minimum, @short_message)
        end

        def allows_maximum_length
          allows_length_of(@maximum, @long_message)
        end

        def allows_length_of(length, message)
          return true if length.nil?
          @allow = AllowValueMatcher.
            new(value_of_length(length)).
            for(@attribute).
            with_message(message)
          if @allow.matches?(@subject)
            @negative_failure_message = @allow.failure_message
            true
          else
            @failure_message = @allow.negative_failure_message
            false
          end
        end

        def disallows_length_of(length, message)
          @disallow = AllowValueMatcher.
            new(value_of_length(length)).
            for(@attribute).
            with_message(message)
          if @disallow.matches?(@subject)
            @failure_message = @disallow.negative_failure_message
            false
          else
            @negative_failure_message = @disallow.failure_message
            true
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
