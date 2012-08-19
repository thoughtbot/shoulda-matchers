module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:

      # Ensure that the attribute's value is not in the range specified
      #
      # Options:
      # * <tt>in_array</tt> - the array of not allowed values for this attribute
      # * <tt>in_range</tt> - the range of not allowed values for this attribute
      # * <tt>with_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt>. Regexp or string. Defaults to the
      #   translation for :exclusion.
      #
      # Example:
      #   it { should ensure_exclusion_of(:age).in_range(30..60) }
      #
      def ensure_exclusion_of(attr)
        EnsureExclusionOfMatcher.new(attr)
      end

      class EnsureExclusionOfMatcher < ValidationMatcher # :nodoc:
        def in_array(array)
          @array = array
          self
        end

        def in_range(range)
          @range = range
          @minimum = range.first
          @maximum = range.last
          self
        end

        def with_message(message)
          @expected_message = message if message
          self
        end

        def description
          "ensure exclusion of #{@attribute} in #{inspect_message}"
        end

        def matches?(subject)
          super(subject)

          if @range
            allows_lower_value &&
              disallows_minimum_value &&
              allows_higher_value &&
              disallows_maximum_value
          elsif @array
            disallows_all_values_in_array?
          end
        end

        private

        def disallows_all_values_in_array?
          @array.all? do |value|
            disallows_value_of(value, expected_message)
          end
        end

        def allows_lower_value
          @minimum == 0 || allows_value_of(@minimum - 1, expected_message)
        end

        def allows_higher_value
          allows_value_of(@maximum + 1, expected_message)
        end

        def disallows_minimum_value
          disallows_value_of(@minimum, expected_message)
        end

        def disallows_maximum_value
          disallows_value_of(@maximum, expected_message)
        end

        def expected_message
          @expected_message || :exclusion
        end

        def inspect_message
          if @range
            @range.inspect
          else
            @array.inspect
          end
        end
      end
    end
  end
end
