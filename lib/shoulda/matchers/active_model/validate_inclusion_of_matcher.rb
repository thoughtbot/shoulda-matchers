require 'bigdecimal'

module Shoulda
  module Matchers
    module ActiveModel
      # The `validate_inclusion_of` matcher tests usage of the
      # `validates_inclusion_of` validation, asserting that an attribute can
      # take a whitelist of values and cannot take values outside of this list.
      #
      # If your whitelist is an array of values, use `in_array`:
      #
      #     class Issue
      #       include ActiveModel::Model
      #       attr_accessor :state
      #
      #       validates_inclusion_of :state, in: %w(open resolved unresolved)
      #     end
      #
      #     # RSpec
      #     describe Issue do
      #       it do
      #         should validate_inclusion_of(:state).
      #           in_array(%w(open resolved unresolved))
      #       end
      #     end
      #
      #     # Test::Unit
      #     class IssueTest < ActiveSupport::TestCase
      #       should validate_inclusion_of(:state).
      #         in_array(%w(open resolved unresolved))
      #     end
      #
      # If your whitelist is a range of values, use `in_range`:
      #
      #     class Issue
      #       include ActiveModel::Model
      #       attr_accessor :priority
      #
      #       validates_inclusion_of :priority, in: 1..5
      #     end
      #
      #     # RSpec
      #     describe Issue do
      #       it { should validate_inclusion_of(:state).in_range(1..5) }
      #     end
      #
      #     # Test::Unit
      #     class IssueTest < ActiveSupport::TestCase
      #       should validate_inclusion_of(:state).in_range(1..5)
      #     end
      #
      # #### Caveats
      #
      # We discourage using `validate_inclusion_of` with boolean columns. In
      # fact, there is never a case where a boolean column will be anything but
      # true, false, or nil, as ActiveRecord will type-cast an incoming value to
      # one of these three values. That means there isn't any way we can refute
      # this logic in a test. Hence, this will produce a warning:
      #
      #     it { should validate_inclusion_of(:imported).in_array([true, false]) }
      #
      # The only case where `validate_inclusion_of` *could* be appropriate is
      # for ensuring that a boolean column accepts nil, but we recommend
      # using `allow_value` instead, like this:
      #
      #     it { should allow_value(nil).for(:imported) }
      #
      # #### Qualifiers
      #
      # ##### with_message
      #
      # Use `with_message` if you are using a custom validation message.
      #
      #     class Issue
      #       include ActiveModel::Model
      #       attr_accessor :severity
      #
      #       validates_inclusion_of :severity,
      #         in: %w(low medium high),
      #         message: 'Severity must be low, medium, or high'
      #     end
      #
      #     # RSpec
      #     describe Issue do
      #       it do
      #         should validate_inclusion_of(:severity).
      #           in_array(%w(low medium high)).
      #           with_message('Severity must be low, medium, or high')
      #       end
      #     end
      #
      #     # Test::Unit
      #     class IssueTest < ActiveSupport::TestCase
      #       should validate_inclusion_of(:severity).
      #         in_array(%w(low medium high)).
      #         with_message('Severity must be low, medium, or high')
      #     end
      #
      # ##### with_low_message
      #
      # Use `with_low_message` if you have a custom validation message for when
      # a given value is too low.
      #
      #     class Person
      #       include ActiveModel::Model
      #       attr_accessor :age
      #
      #       validate :age_must_be_valid
      #
      #       private
      #
      #       def age_must_be_valid
      #         if age < 65
      #           self.errors.add :age, 'You do not receive any benefits'
      #         end
      #       end
      #     end
      #
      #     # RSpec
      #     describe Person do
      #       it do
      #         should validate_inclusion_of(:age).
      #           in_range(0..65).
      #           with_low_message('You do not receive any benefits')
      #       end
      #     end
      #
      #     # Test::Unit
      #     class PersonTest < ActiveSupport::TestCase
      #       should validate_inclusion_of(:age).
      #         in_range(0..65).
      #         with_low_message('You do not receive any benefits')
      #     end
      #
      # ##### with_high_message
      #
      # Use `with_high_message` if you have a custom validation message for
      # when a given value is too high.
      #
      #     class Person
      #       include ActiveModel::Model
      #       attr_accessor :age
      #
      #       validate :age_must_be_valid
      #
      #       private
      #
      #       def age_must_be_valid
      #         if age > 21
      #           self.errors.add :age, "You're too old for this stuff"
      #         end
      #       end
      #     end
      #
      #     # RSpec
      #     describe Person do
      #       it do
      #         should validate_inclusion_of(:age).
      #           in_range(0..21).
      #           with_high_message("You're too old for this stuff")
      #       end
      #     end
      #
      #     # Test::Unit
      #     class PersonTest < ActiveSupport::TestCase
      #       should validate_inclusion_of(:age).
      #         in_range(0..21).
      #         with_high_message("You're too old for this stuff")
      #     end
      #
      # ##### allow_nil
      #
      # Use `allow_nil` to assert that the attribute allows nil.
      #
      #     class Issue
      #       include ActiveModel::Model
      #       attr_accessor :state
      #
      #       validates_presence_of :state
      #       validates_inclusion_of :state,
      #         in: %w(open resolved unresolved),
      #         allow_nil: true
      #     end
      #
      #     # RSpec
      #     describe Issue do
      #       it do
      #         should validate_inclusion_of(:state).
      #           in_array(%w(open resolved unresolved)).
      #           allow_nil
      #       end
      #     end
      #
      #     # Test::Unit
      #     class IssueTest < ActiveSupport::TestCase
      #       should validate_inclusion_of(:state).
      #         in_array(%w(open resolved unresolved)).
      #         allow_nil
      #     end
      #
      # ##### allow_blank
      #
      # Use `allow_blank` to assert that the attribute allows blank.
      #
      #     class Issue
      #       include ActiveModel::Model
      #       attr_accessor :state
      #
      #       validates_presence_of :state
      #       validates_inclusion_of :state,
      #         in: %w(open resolved unresolved),
      #         allow_blank: true
      #     end
      #
      #     # RSpec
      #     describe Issue do
      #       it do
      #         should validate_inclusion_of(:state).
      #           in_array(%w(open resolved unresolved)).
      #           allow_blank
      #       end
      #     end
      #
      #     # Test::Unit
      #     class IssueTest < ActiveSupport::TestCase
      #       should validate_inclusion_of(:state).
      #         in_array(%w(open resolved unresolved)).
      #         allow_blank
      #     end
      #
      # @return [ValidateInclusionOfMatcher]
      #
      def validate_inclusion_of(attr)
        ValidateInclusionOfMatcher.new(attr)
      end

      # @deprecated Use {#validate_inclusion_of} instead.
      # @return [ValidateInclusionOfMatcher]
      def ensure_inclusion_of(attr)
        Shoulda::Matchers.warn_about_deprecated_method(
          :ensure_inclusion_of,
          :validate_inclusion_of
        )
        validate_inclusion_of(attr)
      end

      # @private
      class ValidateInclusionOfMatcher < ValidationMatcher
        ARBITRARY_OUTSIDE_STRING = 'shouldamatchersteststring'
        ARBITRARY_OUTSIDE_FIXNUM = 123456789
        ARBITRARY_OUTSIDE_DECIMAL = BigDecimal.new('0.123456789')
        BOOLEAN_ALLOWS_BOOLEAN_MESSAGE = <<EOT
You are using `validate_inclusion_of` to assert that a boolean column allows
boolean values and disallows non-boolean ones. Be aware that it is not possible
to fully test this, as boolean columns will automatically convert non-boolean
values to boolean ones. Hence, you should consider removing this test.
EOT
        BOOLEAN_ALLOWS_NIL_MESSAGE = <<EOT
You are using `validate_inclusion_of` to assert that a boolean column allows nil.
Be aware that it is not possible to fully test this, as anything other than
true, false or nil will be converted to false. Hence, you should consider
removing this test.
EOT

        def initialize(attribute)
          super(attribute)
          @options = {}
          @array = nil
          @range = nil
          @minimum = nil
          @maximum = nil
          @low_message = nil
          @high_message = nil
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
            when [false, true], [true, false]
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

          !values_outside_of_array.any? do |value|
            allows_value_of(value, @low_message)
          end
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
