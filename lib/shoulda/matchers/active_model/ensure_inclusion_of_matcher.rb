module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:

      # Ensure that the attribute's value is in the range specified
      #
      # Options:
      # * <tt>in_array</tt> - the array of allowed values for this attribute
      # * <tt>in_range</tt> - the range of allowed values for this attribute
      # * <tt>with_low_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt>. Regexp or string. Defaults to the
      #   translation for :inclusion.
      # * <tt>with_high_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt>. Regexp or string. Defaults to the
      #   translation for :inclusion.
      #
      # Example:
      #   it { should ensure_inclusion_of(:age).in_range(0..100) }
      #
      def ensure_inclusion_of(attr)
        EnsureInclusionOfMatcher.new(attr)
      end

      class EnsureInclusionOfMatcher < ValidationMatcher # :nodoc:
        ARBITRARY_OUTSIDE_STRING = 'shouldamatchersteststring'

        def initialize(attribute)
          super(attribute)
          @options = {}
        end

        def in_array(array)
          @array = array
          self
        end

        def in_range(range)
          @range = range
          @minimum = range.first
          @maximum = range.max
          self
        end

        def allow_blank(allow_blank = true)
          @options[:allow_blank] = allow_blank
          self
        end

        def allow_nil(allow_nil = true)
          @options[:allow_nil] = allow_nil
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
          "ensure inclusion of #{@attribute} in #{inspect_message}"
        end

        def matches?(subject)
          super(subject)

          if @range
            @low_message  ||= :inclusion
            @high_message ||= :inclusion

            disallows_lower_value &&
              allows_minimum_value &&
              disallows_higher_value &&
              allows_maximum_value
          elsif @array
            if allows_all_values_in_array? && allows_blank_value? && allows_nil_value? && disallows_value_outside_of_array?
              true
            else
              @failure_message_for_should = "#{@array} doesn't match array in validation"
              false
            end
          end
        end

        private

        def allows_blank_value?
          if @options.key?(:allow_blank)
            blank_values = ['', ' ', "\n", "\r", "\t", "\f"]
            @options[:allow_blank] == blank_values.all? { |value| allows_value_of(value) }
          else
            true
          end
        end

        def allows_nil_value?
          if @options.key?(:allow_nil)
            @options[:allow_nil] == allows_value_of(nil)
          else
            true
          end
        end

        def inspect_message
          @range.nil? ? @array.inspect : @range.inspect
        end

        def allows_all_values_in_array?
          @array.all? do |value|
            allows_value_of(value, @low_message)
          end
        end

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

        def disallows_value_outside_of_array?
          disallows_value_of(value_outside_of_array)
        end

        def value_outside_of_array
          if @array.include?(ARBITRARY_OUTSIDE_STRING)
            raise CouldNotDetermineValueOutsideOfArray
          else
            ARBITRARY_OUTSIDE_STRING
          end
        end
      end
    end
  end
end
