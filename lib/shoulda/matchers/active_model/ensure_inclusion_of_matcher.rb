require 'bigdecimal'

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
        ARBITRARY_OUTSIDE_FIXNUM = 123456789
        ARBITRARY_OUTSIDE_DECIMAL = BigDecimal.new('0.123456789')
        BOOLEAN_ALLOWS_BOOLEAN_MESSAGE = <<EOT
You are using `ensure_inclusion_of` to assert that a boolean column allows
boolean values and disallows non-boolean ones. Assuming you are using
`validates_format_of` in your model, be aware that it is not possible to fully
test this, and in fact the validation is superfluous, as boolean columns will
automatically convert non-boolean values to boolean ones. Hence, you should
consider removing this test and the corresponding validation.
EOT
        BOOLEAN_ALLOWS_NIL_MESSAGE = <<EOT
You are using `ensure_inclusion_of` to assert that a boolean column allows nil.
Be aware that it is not possible to fully test this, as anything other than
true, false or nil will be converted to false. Hence, you should consider
removing this test and the corresponding validation.
EOT

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
            matches_for_range?
          elsif @array
            if matches_for_array?
              true
            else
              @failure_message = "#{@array} doesn't match array in validation"
              false
            end
          end
        end

        private

        def matches_for_range?
          disallows_lower_value &&
            allows_minimum_value &&
            disallows_higher_value &&
            allows_maximum_value
        end

        def matches_for_array?
          allows_all_values_in_array? &&
            allows_blank_value? &&
            allows_nil_value? &&
            disallows_value_outside_of_array?
        end

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
          if attribute_type == :boolean
            case @array
            when [true, false]
              Shoulda::Matchers.warn BOOLEAN_ALLOWS_BOOLEAN_MESSAGE
              return true
            when [nil]
              if attribute_column.null
                Shoulda::Matchers.warn BOOLEAN_ALLOWS_NIL_MESSAGE
                return true
              else
                raise NonNullableBooleanError.create(@attribute)
              end
            end
          end

          !allows_value_of(*values_outside_of_array)
        end

        def values_outside_of_array
          if !(@array & outside_values).empty?
            raise CouldNotDetermineValueOutsideOfArray
          else
            outside_values
          end
        end

        def outside_values
          case attribute_type
          when :boolean
            boolean_outside_values
          when :fixnum
            [ARBITRARY_OUTSIDE_FIXNUM]
          when :decimal
            [ARBITRARY_OUTSIDE_DECIMAL]
          else
            [ARBITRARY_OUTSIDE_STRING]
          end
        end

        def boolean_outside_values
          values = []

          values << case @array
            when [true]  then false
            when [false] then true
            else              raise CouldNotDetermineValueOutsideOfArray
          end

          if attribute_allows_nil?
            values << nil
          end

          values
        end

        def attribute_type
          if attribute_column
            column_type_to_attribute_type(attribute_column.type)
          else
            value_to_attribute_type(@subject.__send__(@attribute))
          end
        end

        def attribute_allows_nil?
          if attribute_column
            attribute_column.null
          else
            true
          end
        end

        def attribute_column
          if @subject.class.respond_to?(:columns_hash)
            @subject.class.columns_hash[@attribute.to_s]
          end
        end

        def column_type_to_attribute_type(type)
          case type
            when :boolean, :decimal then type
            when :integer, :float then :fixnum
            else :default
          end
        end

        def value_to_attribute_type(value)
          case value
            when true, false then :boolean
            when BigDecimal then :decimal
            when Fixnum then :fixnum
            else :default
          end
        end
      end
    end
  end
end
