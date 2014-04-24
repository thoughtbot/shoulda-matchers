require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::EnsureInclusionOfMatcher do
  shared_context 'for a generic attribute' do
    def self.testing_values_of_option(option_name, &block)
      [nil, true, false].each do |option_value|
        context_name = "+ #{option_name}"
        option_args = []
        matches_or_not = ['matches', 'does not match']
        to_or_not_to = [:to, :not_to]

        unless option_value == nil
          context_name << "(#{option_value})"
          option_args = [option_value]
        end

        if option_value == false
          matches_or_not.reverse!
          to_or_not_to.reverse!
        end

      end
    end

    context 'against an integer attribute' do
      it_behaves_like 'it supports in_array',
        possible_values: (1..5).to_a,
        zero: 0,
        reserved_outside_value: described_class::ARBITRARY_OUTSIDE_FIXNUM

      it_behaves_like 'it supports in_range',
        possible_values: 1..5,
        zero: 0

      context 'when attribute validates a range of values via custom validation' do
        it 'matches ensuring the correct range and messages' do
          expect_to_match_ensuring_range_and_messages(2..5, 2, 5)
          expect_to_match_ensuring_range_and_messages(2...5, 2, 4)
        end
      end

      def build_object(options = {}, &block)
        build_object_with_generic_attribute(
          options.merge(column_type: :integer, value: 1),
          &block
        )
      end

      def add_outside_value_to(values)
        values + [values.last + 1]
      end
    end

    context "against a float attribute" do
      it_behaves_like 'it supports in_array',
        possible_values: [1.0, 2.0, 3.0, 4.0, 5.0],
        zero: 0.0,
        reserved_outside_value: described_class::ARBITRARY_OUTSIDE_FIXNUM

      it_behaves_like 'it supports in_range',
        possible_values: 1.0..5.0,
        zero: 0.0

      def build_object(options = {}, &block)
        build_object_with_generic_attribute(
          options.merge(column_type: :float, value: 1.0),
          &block
        )
      end

      def add_outside_value_to(values)
        values + [values.last + 1]
      end
    end

    context "against a decimal attribute" do
      it_behaves_like 'it supports in_array',
        possible_values: [1.0, 2.0, 3.0, 4.0, 5.0].map { |number|
          BigDecimal.new(number.to_s)
        },
        zero: BigDecimal.new('0.0'),
        reserved_outside_value: described_class::ARBITRARY_OUTSIDE_DECIMAL

      it_behaves_like 'it supports in_range',
        possible_values: BigDecimal.new('1.0') .. BigDecimal.new('5.0'),
        zero: BigDecimal.new('0.0')

      def build_object(options = {}, &block)
        build_object_with_generic_attribute(
          options.merge(column_type: :decimal, value: BigDecimal.new('1.0')),
          &block
        )
      end

      def add_outside_value_to(values)
        values + [values.last + 1]
      end
    end

    context 'against a string attribute' do
      it_behaves_like 'it supports in_array',
        possible_values: %w(foo bar baz),
        reserved_outside_value: described_class::ARBITRARY_OUTSIDE_STRING

      def build_object(options = {}, &block)
        build_object_with_generic_attribute(
          options.merge(column_type: :string),
          &block
        )
      end

      def add_outside_value_to(values)
        values + %w(qux)
      end
    end
  end

  shared_examples_for 'it supports allow_nil' do |args|
    valid_values = args.fetch(:valid_values)

    testing_values_of_option 'allow_nil' do |option_args, matches_or_not, to_or_not_to|
      it "#{matches_or_not[0]} when the validation specifies allow_nil" do
        builder = build_object_allowing(valid_values, allow_nil: true)

        __send__("expect_#{to_or_not_to[0]}_match_on_values", builder, valid_values) do |matcher|
          matcher.allow_nil(*option_args)
        end
      end

      it "#{matches_or_not[1]} when the validation does not specify allow_nil" do
        builder = build_object_allowing(valid_values)

        __send__("expect_#{to_or_not_to[1]}_match_on_values", builder, valid_values) do |matcher|
          matcher.allow_nil(*option_args)
        end
      end
    end
  end

  shared_examples_for 'it supports allow_blank' do |args|
    valid_values = args.fetch(:valid_values)

    testing_values_of_option 'allow_blank' do |option_args, matches_or_not, to_or_not_to|
      it "#{matches_or_not[0]} when the validation specifies allow_blank" do
        builder = build_object_allowing(valid_values, allow_blank: true)

        __send__("expect_#{to_or_not_to[0]}_match_on_values", builder, valid_values) do |matcher|
          matcher.allow_blank(*option_args)
        end
      end

      it "#{matches_or_not[1]} when the validation does not specify allow_blank" do
        builder = build_object_allowing(valid_values)

        __send__("expect_#{to_or_not_to[1]}_match_on_values", builder, valid_values) do |matcher|
          matcher.allow_blank(*option_args)
        end
      end
    end
  end

  shared_examples_for 'it supports with_message' do |args|
    valid_values = args.fetch(:valid_values)

    context 'given a string' do
      it 'matches when validation uses given message' do
        builder = build_object_allowing(valid_values, message: 'a message')

        expect_to_match_on_values(builder, valid_values) do |matcher|
          matcher.with_message('a message')
        end
      end

      it 'does not match when validation uses the default message instead of given message' do
        pending 'does not work'

        builder = build_object_allowing(valid_values)

        expect_not_to_match_on_values(builder, valid_values) do |matcher|
          matcher.with_message('a message')
        end
      end

      it 'does not match when validation uses a message but it is not same as given' do
        pending 'does not work'

        builder = build_object_allowing(valid_values, message: 'a different message')

        expect_not_to_match_on_values(builder, valid_values) do |matcher|
          matcher.with_message('a message')
        end
      end
    end

    context 'given a regex' do
      it 'matches when validation uses a message that matches the regex' do
        builder = build_object_allowing(valid_values, message: 'this is a message')

        expect_to_match_on_values(builder, valid_values) do |matcher|
          matcher.with_message(/a message/)
        end
      end

      it 'does not match when validation uses the default message instead of given message' do
        pending 'does not work'

        builder = build_object_allowing(valid_values)

        expect_not_to_match_on_values(builder, valid_values) do |matcher|
          matcher.with_message(/a message/)
        end
      end

      it 'does not match when validation uses a message but it does not match regex' do
        pending 'does not work'

        builder = build_object_allowing(valid_values, message: 'a different message')

        expect_not_to_match_on_values(builder, valid_values) do |matcher|
          matcher.with_message(/a message/)
        end
      end
    end

    context 'given nil' do
      it 'is as if with_message had never been called' do
        builder = build_object_allowing(valid_values)

        expect_to_match_on_values(builder, valid_values) do |matcher|
          matcher.with_message(nil)
        end
      end
    end
  end

  shared_examples_for 'it supports in_array' do |args|
    possible_values = args.fetch(:possible_values)
    zero = args[:zero]
    reserved_outside_value = args.fetch(:reserved_outside_value)

    it 'does not match a record with no validations' do
      builder = build_object
      expect_not_to_match_on_values(builder, possible_values)
    end

    it 'matches given the same array of valid values' do
      builder = build_object_allowing(possible_values)
      expect_to_match_on_values(builder, possible_values)
    end

    it 'matches given a subset of the valid values' do
      builder = build_object_allowing(possible_values)
      expect_to_match_on_values(builder, possible_values[1..-1])
    end

    if zero
      it 'matches when one of the given values is a 0' do
        valid_values = possible_values + [zero]
        builder = build_object_allowing(valid_values)
        expect_to_match_on_values(builder, valid_values)
      end
    end

    it 'does not match when one of the given values is invalid' do
      builder = build_object_allowing(possible_values)
      expect_not_to_match_on_values(builder, add_outside_value_to(possible_values))
    end

    it 'raises an error when valid and given value is our test outside value' do
      error_class = Shoulda::Matchers::ActiveModel::CouldNotDetermineValueOutsideOfArray
      builder = build_object_allowing([reserved_outside_value])

      expect { expect_to_match_on_values(builder, [reserved_outside_value]) }.
        to raise_error(error_class)
    end

    it_behaves_like 'it supports allow_nil', valid_values: possible_values
    it_behaves_like 'it supports allow_blank', valid_values: possible_values
    it_behaves_like 'it supports with_message', valid_values: possible_values

    if active_model_3_2?
      context '+ strict' do
        context 'when the validation specifies strict' do
          it 'matches when the given values match the valid values' do
            builder = build_object_allowing(possible_values, strict: true)

            expect_to_match_on_values(builder, possible_values) do |matcher|
              matcher.strict
            end
          end

          it 'does not match when the given values do not match the valid values' do
            builder = build_object_allowing(possible_values, strict: true)

            values = add_outside_value_to(possible_values)
            expect_not_to_match_on_values(builder, values) do |matcher|
              matcher.strict
            end
          end
        end

        context 'when the validation does not specify strict' do
          it 'does not match' do
            builder = build_object_allowing(possible_values)

            expect_not_to_match_on_values(builder, possible_values) do |matcher|
              matcher.strict
            end
          end
        end
      end
    end

    def expect_to_match_on_values(builder, values, &block)
      expect_to_match_in_array(builder, values, &block)
    end

    def expect_not_to_match_on_values(builder, values, &block)
      expect_not_to_match_in_array(builder, values, &block)
    end
  end

  shared_examples_for 'it supports in_range' do |args|
    possible_values = args[:possible_values]

    it 'does not match a record with no validations' do
      builder = build_object
      expect_not_to_match_on_values(builder, possible_values)
    end

    it 'matches given a range that exactly matches the valid range' do
      builder = build_object_allowing(possible_values)
      expect_to_match_on_values(builder, possible_values)
    end

    it 'does not match given a range whose start value falls outside valid range' do
      builder = build_object_allowing(possible_values)
      expect_not_to_match_on_values(builder,
        Range.new(possible_values.first - 1, possible_values.last)
      )
    end

    it 'does not match given a range whose start value falls inside valid range' do
      builder = build_object_allowing(possible_values)
      expect_not_to_match_on_values(builder,
        Range.new(possible_values.first + 1, possible_values.last)
      )
    end

    it 'does not match given a range whose end value falls inside valid range' do
      builder = build_object_allowing(possible_values)
      expect_not_to_match_on_values(builder,
        Range.new(possible_values.first, possible_values.last - 1)
      )
    end

    it 'does not match given a range whose end value falls outside valid range' do
      builder = build_object_allowing(possible_values)
      expect_not_to_match_on_values(builder,
        Range.new(possible_values.first, possible_values.last + 1)
      )
    end

    it_behaves_like 'it supports allow_nil', valid_values: possible_values
    it_behaves_like 'it supports allow_blank', valid_values: possible_values
    it_behaves_like 'it supports with_message', valid_values: possible_values

    if active_model_3_2?
      context '+ strict' do
        context 'when the validation specifies strict' do
          it 'matches when the given range matches the range in the validation' do
            builder = build_object_allowing(possible_values, strict: true)

            expect_to_match_on_values(builder, possible_values) do |matcher|
              matcher.strict
            end
          end

          it 'matches when the given range does not match the range in the validation' do
            builder = build_object_allowing(possible_values, strict: true)

            range = Range.new(possible_values.first, possible_values.last + 1)
            expect_not_to_match_on_values(builder, range) do |matcher|
              matcher.strict
            end
          end
        end

        context 'when the validation does not specify strict' do
          it 'does not match' do
            builder = build_object_allowing(possible_values)

            expect_not_to_match_on_values(builder, possible_values) do |matcher|
              matcher.strict
            end
          end
        end
      end
    end

    def expect_to_match_on_values(builder, range, &block)
      expect_to_match_in_range(builder, range, &block)
    end

    def expect_not_to_match_on_values(builder, range, &block)
      expect_not_to_match_in_range(builder, range, &block)
    end
  end

  shared_context 'against a boolean attribute for true and false' do
    context 'when ensuring inclusion of true' do
      it 'matches' do
        valid_values = [true]
        builder = build_object_allowing(valid_values)
        expect_to_match_in_array(builder, valid_values)
      end
    end

    context 'when ensuring inclusion of false' do
      it 'matches' do
        valid_values = [false]
        builder = build_object_allowing(valid_values)
        expect_to_match_in_array(builder, valid_values)
      end
    end

    context 'when ensuring inclusion of true and false' do
      it 'matches' do
        valid_values = [true, false]
        builder = build_object_allowing(valid_values)
        capture(:stderr) do
          expect_to_match_in_array(builder, valid_values)
        end
      end

      it 'prints a warning' do
        valid_values = [true, false]
        builder = build_object_allowing(valid_values)
        message = 'You are using `ensure_inclusion_of` to assert that a boolean column allows boolean values and disallows non-boolean ones'

        stderr = capture(:stderr) do
          expect_to_match_in_array(builder, valid_values)
        end

        expect(stderr.gsub(/\n+/, ' ')).to include(message)
      end
    end
  end

  context 'for a database column' do
    include_context 'for a generic attribute'

    context 'against a boolean attribute' do
      context 'which is nullable' do
        include_context 'against a boolean attribute for true and false'

        context 'when ensuring inclusion of nil' do
          it 'matches' do
            valid_values = [nil]
            builder = build_object_allowing(valid_values)
            capture(:stderr) do
              expect_to_match_in_array(builder, valid_values)
            end
          end

          it 'prints a warning' do
            valid_values = [nil]
            builder = build_object_allowing(valid_values)
            message = 'You are using `ensure_inclusion_of` to assert that a boolean column allows nil'

            stderr = capture(:stderr) do
              expect_to_match_in_array(builder, valid_values)
            end

            expect(stderr.gsub(/\n+/, ' ')).to include(message)
          end
        end

        def build_object(options = {}, &block)
          super(options.merge(column_options: { null: true }, value: true))
        end
      end

      context 'which is non-nullable' do
        include_context 'against a boolean attribute for true and false'

        context 'when ensuring inclusion of nil' do
          it 'raises a specific error' do
            valid_values = [nil]
            builder = build_object_allowing(valid_values)
            error_class = Shoulda::Matchers::ActiveModel::NonNullableBooleanError

            expect {
              expect_to_match_in_array(builder, valid_values)
            }.to raise_error(error_class)
          end
        end

        def build_object(options = {}, &block)
          super(options.merge(column_options: { null: false }))
        end
      end

      def build_object(options = {}, &block)
        build_object_with_generic_attribute(
          options.merge(column_type: :boolean),
          &block
        )
      end
    end


    def build_object_with_generic_attribute(options = {}, &block)
      attribute_name = :attr
      column_type = options.fetch(:column_type)
      column_options = {
        type: column_type,
        options: options.fetch(:column_options, {})
      }
      validation_options = options[:validation_options]
      custom_validation = options[:custom_validation]

      model = define_model :example, attribute_name => column_options
      customize_model_class(
        model,
        attribute_name,
        validation_options,
        custom_validation
      )

      object = model.new

      object_builder_class.new(attribute_name, object, validation_options)
    end
  end

  context 'for a plain Ruby attribute' do
    include_context 'for a generic attribute'

    context 'against a boolean attribute (designated by true)' do
      include_context 'against a boolean attribute for true and false'

      def build_object(options = {}, &block)
        build_object_with_generic_attribute(options.merge(value: true))
      end
    end

    context 'against a boolean attribute (designated by false)' do
      include_context 'against a boolean attribute for true and false'

      def build_object(options = {}, &block)
        build_object_with_generic_attribute(options.merge(value: false))
      end
    end

    def build_object_with_generic_attribute(options = {}, &block)
      attribute_name = :attr
      validation_options = options[:validation_options]
      custom_validation = options[:custom_validation]
      value = options[:value]

      model = define_active_model_class :example, accessors: [attribute_name]
      customize_model_class(
        model,
        attribute_name,
        validation_options,
        custom_validation
      )

      object = model.new
      object.__send__("#{attribute_name}=", value)

      object_builder_class.new(attribute_name, object, validation_options)
    end
  end

  def object_builder_class
    @_object_builder_class ||= Struct.new(:attribute, :object, :validation_options)
  end

  def customize_model_class(klass, attribute_name, validation_options, custom_validation)
    klass.class_eval do
      if validation_options
        validates_inclusion_of attribute_name, validation_options
      end

      if custom_validation
        define_method :custom_validation do
          instance_exec(attribute_name, &custom_validation)
        end

        validate :custom_validation
      end
    end
  end

  def build_object_allowing(values, options = {})
    build_object(validation_options: options.merge(in: values))
  end

  def expect_to_match(builder)
    matcher = ensure_inclusion_of(builder.attribute)
    yield matcher if block_given?
    expect(builder.object).to(matcher)
  end

  def expect_not_to_match(builder)
    matcher = ensure_inclusion_of(builder.attribute)
    yield matcher if block_given?
    expect(builder.object).not_to(matcher)
  end

  def expect_to_match_in_array(builder, array)
    expect_to_match(builder) do |matcher|
      matcher.in_array(array)
      yield matcher if block_given?
    end
  end

  def expect_not_to_match_in_array(builder, array)
    expect_not_to_match(builder) do |matcher|
      matcher.in_array(array)
      yield matcher if block_given?
    end
  end

  def expect_to_match_in_range(builder, range)
    expect_to_match(builder) do |matcher|
      matcher.in_range(range)
      yield matcher if block_given?
    end
  end

  def expect_not_to_match_in_range(builder, range)
    expect_not_to_match(builder) do |matcher|
      matcher.in_range(range)
      yield matcher if block_given?
    end
  end

  def expect_to_match_ensuring_range_and_messages(range, low_value, high_value)
    low_message = 'too low'
    high_message = 'too high'

    builder = build_object custom_validation: ->(attribute) {
      value = __send__(attribute)

      if value < low_value
        errors.add(attribute, low_message)
      elsif value > high_value
        errors.add(attribute, high_message)
      end
    }

    expect_to_match(builder) do |matcher|
      matcher.
        in_range(range).
        with_low_message(low_message).
        with_high_message(high_message)
    end
  end
end
