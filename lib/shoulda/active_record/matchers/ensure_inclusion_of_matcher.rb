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
          if message
            @low_message = message
            @high_message = message
          end
          self
        end

        def with_low_message(message)
          @low_message = message if message
          self
        end

        def with_high_message(message)
          @high_message = message if message
          self
        end

        def description
          "ensure inclusion of #{@attribute} in #{@range.inspect}"
        end

        def matches?(subject)
          super(subject)

          @low_message  ||= :inclusion
          @high_message ||= :inclusion

          disallows_lower_value && 
            allows_minimum_value &&
            disallows_higher_value &&
            allows_maximum_value
        end

        private

        def disallows_lower_value
          @minimum == 0 || disallows_value_of(@minimum - 1, @low_message)
        end

        def disallows_higher_value
          disallows_value_of(@maximum + 1, @high_message)
        end

        def allows_minimum_value
          allows_value_of(@minimum, @low_message)
        end

        def allows_maximum_value
          allows_value_of(@maximum, @high_message)
        end
      end

      def ensure_inclusion_of(attr)
        EnsureInclusionOfMatcher.new(attr)
      end

    end
  end
end
