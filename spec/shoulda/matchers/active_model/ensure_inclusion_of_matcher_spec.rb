require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::EnsureInclusionOfMatcher do
  shared_context 'for a generic attribute' do
    def self.contexts_for_option(option_name, &block)
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
      def build_object(options = {}, &block)
        build_object_with_generic_attribute(
          options.merge(attribute_type: :integer),
          &block
        )
      end

      def build_object_allowing(values, options = {})
        build_object(validation_options: options.merge(in: values))
      end

      context 'using an array of valid values' do
        def expect_to_match_on_values(builder, values)
          expect_to_match(builder) do |matcher|
            matcher.in_array(values)
            yield matcher if block_given?
          end
        end

        def expect_not_to_match_on_values(builder, values)
          expect_not_to_match(builder) do |matcher|
            matcher.in_array(values)
            yield matcher if block_given?
          end
        end

        it 'does not match a record with no validations' do
          builder = build_object
          expect_not_to_match_on_values(builder, [1, 2])
        end

        it 'matches given the same array of valid values' do
          valid_values = [1, 2]
          builder = build_object_allowing(valid_values)
          expect_to_match_on_values(builder, valid_values)
        end

        it 'matches given a subset of the valid values' do
          builder = build_object_allowing([1, 2, 3])
          expect_to_match_on_values(builder, [2, 3])
        end

        it 'matches when one of the given values is a 0' do
          valid_values = [0, 1, 2]
          builder = build_object_allowing(valid_values)
          expect_to_match_on_values(builder, valid_values)
        end

        it 'does not match when one of the given values is invalid' do
          builder = build_object_allowing([0, 1, 2])
          expect_not_to_match_on_values(builder, [1, 2, 3])
        end

        it 'raises an error when valid and given value is our test outside value' do
          value = described_class::ARBITRARY_OUTSIDE_FIXNUM
          error_class = Shoulda::Matchers::ActiveModel::CouldNotDetermineValueOutsideOfArray
          builder = build_object_allowing([value])

          expect { expect_to_match_on_values(builder, [value]) }.
            to raise_error(error_class)
        end

        it_behaves_like 'it supports allow_nil', valid_values: [1, 2, 3]
        it_behaves_like 'it supports allow_blank', valid_values: [1, 2, 3]
        it_behaves_like 'it supports with_message', valid_values: [1, 2, 3]

        if active_model_3_2?
          context '+ strict' do
            context 'when the validation specifies strict' do
              it 'matches when all of the given values are valid' do
                valid_values = [1, 2, 3]
                builder = build_object_allowing(valid_values, strict: true)

                expect_to_match_on_values(builder, valid_values) do |matcher|
                  matcher.strict
                end
              end

              it 'does not match when some of the given are not valid' do
                builder = build_object_allowing([1, 2, 3], strict: true)

                expect_not_to_match_on_values(builder, [2, 3, 4]) do |matcher|
                  matcher.strict
                end
              end
            end

            context 'when the validation does not specify strict' do
              it 'does not match' do
                valid_values = [1, 2, 3]
                builder = build_object_allowing(valid_values)

                expect_not_to_match_on_values(builder, valid_values) do |matcher|
                  matcher.strict
                end
              end
            end
          end
        end
      end

      context 'using a range of valid values' do
        def expect_to_match_on_values(builder, range)
          expect_to_match(builder) do |matcher|
            matcher.in_range(range)
            yield matcher if block_given?
          end
        end

        def expect_not_to_match_on_values(builder, range)
          expect_not_to_match(builder) do |matcher|
            matcher.in_range(range)
            yield matcher if block_given?
          end
        end

        it 'does not match a record with no validations' do
          builder = build_object
          expect_not_to_match_on_values(builder, 1..3)
        end

        it 'matches given a range that exactly matches the valid range' do
          valid_values = 1..3
          builder = build_object_allowing(valid_values)
          expect_to_match_on_values(builder, valid_values)
        end

        it 'does not match given a range whose first value falls outside valid range' do
          builder = build_object_allowing(2..3)
          expect_not_to_match_on_values(builder, 1..3)
        end

        it 'does not match given a range whose first value falls inside valid range' do
          builder = build_object_allowing(1..3)
          expect_not_to_match_on_values(builder, 2..3)
        end

        it 'does not match given a range whose second value falls inside valid range' do
          builder = build_object_allowing(1..3)
          expect_not_to_match_on_values(builder, 1..2)
        end

        it 'does not match given a range whose second value falls outside valid range' do
          builder = build_object_allowing(1..3)
          expect_not_to_match_on_values(builder, 1..4)
        end

        it_behaves_like 'it supports allow_nil', valid_values: 1..3
        it_behaves_like 'it supports allow_blank', valid_values: 1..3
        it_behaves_like 'it supports with_message', valid_values: 1..3

        if active_model_3_2?
          context '+ strict' do
            context 'when the validation specifies strict' do
              it 'matches when all of the given values are valid' do
                valid_values = [1, 2, 3]
                builder = build_object_allowing(valid_values, strict: true)

                expect_to_match_on_values(builder, valid_values) do |matcher|
                  matcher.strict
                end
              end

              it 'does not match when some of the given are not valid' do
                builder = build_object_allowing([1, 2, 3], strict: true)

                expect_not_to_match_on_values(builder, [2, 3, 4]) do |matcher|
                  matcher.strict
                end
              end
            end

            context 'when the validation does not specify strict' do
              it 'does not match' do
                valid_values = [1, 2, 3]
                builder = build_object_allowing(valid_values)

                expect_not_to_match_on_values(builder, valid_values) do |matcher|
                  matcher.strict
                end
              end
            end
          end
        end
      end

      context 'when attribute validates a range of values via custom validation' do
        it 'matches ensuring the correct range and messages' do
          expect_to_match_ensuring_range_and_messages(2..5, 2, 5)
          expect_to_match_ensuring_range_and_messages(2...5, 2, 4)
        end

        def expect_to_match_ensuring_range_and_messages(range, low_value, high_value)
          low_message = 'too low'
          high_message = 'too high'

          builder = build_object do |attribute|
            value = __send__(attribute)

            if value < low_value
              errors.add(attribute, low_message)
            elsif value > high_value
              errors.add(attribute, high_message)
            end
          end

          expect_to_match(builder) do |matcher|
            matcher.
              in_range(range).
              with_low_message(low_message).
              with_high_message(high_message)
          end
        end
      end
    end

    %w(float decimal).each do |attribute_type|
      context "against a #{attribute_type} attribute" do
        # copy from above
      end
    end

    context 'against a boolean attribute' do
      # copy from above
      # and possibly custom stuff?
    end

    context 'against a string attribute' do
      it 'does not match a record with no validations' do
        builder = build_object_with_generic_attribute(attribute_type: :string)
        expect(builder.object).
          not_to ensure_inclusion_of(builder.attribute).
          in_array(%w(Yes No))
      end

      # copy from above
    end
  end

  shared_examples_for 'it supports allow_nil' do |args|
    valid_values = args.fetch(:valid_values)

    contexts_for_option 'allow_nil' do |option_args, matches_or_not, to_or_not_to|
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

    contexts_for_option 'allow_blank' do |option_args, matches_or_not, to_or_not_to|
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

  context 'for a database column' do
    include_context 'for a generic attribute'

    def build_object_with_generic_attribute(options = {}, &block)
      attribute_name = :attr
      attribute_type = options.fetch(:attribute_type)
      validation_options = options[:validation_options]

      model = define_model :example, attribute_name => attribute_type do
        if validation_options
          validates_inclusion_of attribute_name, validation_options
        end

        if block
          define_method :custom_validation do
            instance_exec(attribute_name, &block)
          end

          validate :custom_validation
        end
      end

      object = model.new

      builder_class.new(attribute_name, object, validation_options)
    end
  end

  def builder_class
    @_builder_class ||= Struct.new(:attribute, :object, :validation_options)
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

=begin
    context 'where the value given is the same as one of our "outside values"' do
      context 'for a boolean attribute' do
        it 'raises a CouldNotDetermineValueOutsideOfArray error' do
          arbitrary_string = described_class::ARBITRARY_OUTSIDE_STRING
          error_class = Shoulda::Matchers::ActiveModel::CouldNotDetermineValueOutsideOfArray
          builder = build_object_with_generic_attribute(attribute_type: :string)

          expect {
            expect(builder.object).
              to ensure_inclusion_of(builder.attribute).
              in_array([arbitrary_string])
          }.to_raise_error(error_class)
        end
      end

      context 'for an integer attribute' do
        it 'raises a CouldNotDetermineValueOutsideOfArray error' do
          arbitrary_fixnum = described_class::ARBITRARY_OUTSIDE_FIXNUM
          error_class = Shoulda::Matchers::ActiveModel::CouldNotDetermineValueOutsideOfArray
          builder = build_object_with_generic_attribute(attribute_type: :integer)

          expect {
            expect(builder.object).
              to ensure_inclusion_of(builder.attribute).
              in_array([arbitrary_fixnum])
          }.to_raise_error(error_class)
        end
      end

      context 'for a float attribute' do
        it 'raises a CouldNotDetermineValueOutsideOfArray error' do
          arbitrary_fixnum = described_class::ARBITRARY_OUTSIDE_FIXNUM
          error_class = Shoulda::Matchers::ActiveModel::CouldNotDetermineValueOutsideOfArray
          builder = build_object_with_generic_attribute(attribute_type: :float)

          expect {
            expect(builder.object).
              to ensure_inclusion_of(builder.attribute).
              in_array([arbitrary_float])
          }.to_raise_error(error_class)
        end
      end

      context 'for a decimal attribute' do
        it 'raises a CouldNotDetermineValueOutsideOfArray error' do
          arbitrary_decimal = described_class::ARBITRARY_OUTSIDE_DECIMAL
          error_class = Shoulda::Matchers::ActiveModel::CouldNotDetermineValueOutsideOfArray
          builder = build_object_with_generic_attribute(attribute_type: :decimal)

          expect {
            expect(builder.object).
              to ensure_inclusion_of(builder.attribute).
              in_array([arbitrary_decimal])
          }.to_raise_error(error_class)
        end
      end

      context 'for a string attribute' do
        it 'raises a CouldNotDetermineValueOutsideOfArray error' do
          arbitrary_string = described_class::ARBITRARY_OUTSIDE_STRING
          error_class = Shoulda::Matchers::ActiveModel::CouldNotDetermineValueOutsideOfArray
          builder = build_object_with_generic_attribute(attribute_type: :string)

          expect {
            expect(builder.object).
              to ensure_inclusion_of(builder.attribute).
              in_array([arbitrary_string])
          }.to_raise_error(error_class)
        end
      end
    end

    context 'checking that an attribute is included in a range' do
      it 'accepts a record that validates using the same range' do
        builder = build_object_with_generic_attribute(
          attribute_type: :integer,
          validation_options: { in: 2..5 }
        )

        expect(builder.object).
          to ensure_inclusion_of(builder.attribute).
          in_range(builder.validation_options[:in])
      end

      it 'rejects ensuring a lower minimum value' do
        expect(validating_inclusion(in: 2..5)).
          not_to ensure_inclusion_of(:attr).in_range(1..5)
      end

      it 'rejects ensuring a higher minimum value' do
        expect(validating_inclusion(in: 2..5)).
          not_to ensure_inclusion_of(:attr).in_range(3..5)
      end

      it 'rejects ensuring a lower maximum value' do
        expect(validating_inclusion(in: 2..5)).
          not_to ensure_inclusion_of(:attr).in_range(2..4)
      end

      it 'rejects ensuring a higher maximum value' do
        expect(validating_inclusion(in: 2..5)).
          not_to ensure_inclusion_of(:attr).in_range(2..6)
      end

      it 'does not override the default message with a blank' do
        expect(validating_inclusion(in: 2..5)).
          to ensure_inclusion_of(:attr).in_range(2..5).with_message(nil)
      end
    end

    context 'an attribute which must be included in a range with excluded end' do
      it 'accepts ensuring the correct range' do
        expect(validating_inclusion(in: 2...5)).
          to ensure_inclusion_of(:attr).in_range(2...5)
      end

      it 'rejects ensuring a lower maximum value' do
        expect(validating_inclusion(in: 2...5)).
          not_to ensure_inclusion_of(:attr).in_range(2...4)
      end
    end

    context 'an attribute with a custom ranged value validation' do
      it 'accepts ensuring the correct range' do
        expect(validating_inclusion(in: 2..4, message: 'not good')).
          to ensure_inclusion_of(:attr).in_range(2..4).with_message(/not good/)
      end
    end

    context 'an attribute with custom range validations' do
      it 'accepts ensuring the correct range and messages' do
        model = custom_validation do
          if attr < 2
            errors.add(:attr, 'too low')
          elsif attr > 5
            errors.add(:attr, 'too high')
          end
        end

        expect(model).to ensure_inclusion_of(:attr).in_range(2..5).
          with_low_message(/low/).with_high_message(/high/)

        model = custom_validation do
          if attr < 2
            errors.add(:attr, 'too low')
          elsif attr > 4
            errors.add(:attr, 'too high')
          end
        end

        expect(model).to ensure_inclusion_of(:attr).in_range(2...5).
          with_low_message(/low/).with_high_message(/high/)
      end
    end

    context 'an attribute which must be included in an array' do
      it 'accepts with correct array' do
        expect(validating_inclusion(in: %w(one two))).
          to ensure_inclusion_of(:attr).in_array(%w(one two))
      end

      it 'rejects when only part of array matches' do
        expect(validating_inclusion(in: %w(one two))).
          not_to ensure_inclusion_of(:attr).in_array(%w(one wrong_value))
      end

      it 'rejects when array does not match at all' do
        expect(validating_inclusion(in: %w(one two))).
          not_to ensure_inclusion_of(:attr).in_array(%w(cat dog))
      end

      it 'has correct description' do
        expect(ensure_inclusion_of(:attr).in_array([true, "dog"]).description).
          to eq 'ensure inclusion of attr in [true, "dog"]'
      end

      it 'rejects allow_blank' do
        expect(validating_inclusion(in: %w(one two))).
          not_to ensure_inclusion_of(:attr).in_array(%w(one two)).allow_blank(true)
      end

      it 'accepts allow_blank(false)' do
        expect(validating_inclusion(in: %w(one two))).
          to ensure_inclusion_of(:attr).in_array(%w(one two)).allow_blank(false)
      end

      it 'rejects allow_nil' do
        expect(validating_inclusion(in: %w(one two))).
          not_to ensure_inclusion_of(:attr).in_array(%w(one two)).allow_nil(true)
      end

      it 'accepts allow_nil(false)' do
        expect(validating_inclusion(in: %w(one two))).
          to ensure_inclusion_of(:attr).in_array(%w(one two)).allow_nil(false)
      end
    end

    context 'with allowed blank and allowed nil' do
      it 'accepts allow_blank' do
        expect(validating_inclusion(in: %w(one two), allow_blank: true)).
          to ensure_inclusion_of(:attr).in_array(%w(one two)).allow_blank
      end

      it 'rejects allow_blank(false)' do
        expect(validating_inclusion(in: %w(one two), allow_blank: true)).
          not_to ensure_inclusion_of(:attr).in_array(%w(one two)).allow_blank(false)
      end

      it 'accepts allow_nil' do
        expect(validating_inclusion(in: %w(one two), allow_nil: true)).
          to ensure_inclusion_of(:attr).in_array(%w(one two)).allow_nil
      end

      it 'rejects allow_nil' do
        expect(validating_inclusion(in: %w(one two), allow_nil: true)).
          not_to ensure_inclusion_of(:attr).in_array(%w(one two)).allow_nil(false)
      end
    end

    context 'an attribute allowing some blank values but not others' do
      it 'rejects allow_blank' do
        expect(validating_inclusion(in: ['one', 'two', ''])).
          not_to ensure_inclusion_of(:attr).in_array(['one', 'two', '']).allow_blank(true)
      end
    end

    if active_model_3_2?
      context 'a strict attribute which must be included in a range' do
        it 'accepts ensuring the correct range' do
          expect(validating_inclusion(in: 2..5, strict: true)).
            to ensure_inclusion_of(:attr).in_range(2..5).strict
        end

        it 'rejects ensuring another range' do
          expect(validating_inclusion(in: 2..5, strict: true)).
            not_to ensure_inclusion_of(:attr).in_range(2..6).strict
        end
      end
    end

    context 'against a boolean attribute' do
      context 'which is nullable' do
        context 'when ensuring inclusion of true' do
          it "doesn't raise an error" do
            record = validating_inclusion_of_boolean_in(:attr, [true], null: true)
            expect(record).to ensure_inclusion_of(:attr).in_array([true])
          end
        end

        context 'when ensuring inclusion of false' do
          it "doesn't raise an error" do
            record = validating_inclusion_of_boolean_in(:attr, [false], null: true)
            expect(record).to ensure_inclusion_of(:attr).in_array([false])
          end
        end

        context 'when ensuring inclusion of true and false' do
          it "doesn't raise an error" do
            record = validating_inclusion_of_boolean_in(:attr, [true, false], null: true)
            capture(:stderr) do
              expect(record).to ensure_inclusion_of(:attr).in_array([true, false])
            end
          end

          it 'prints a warning' do
            record = validating_inclusion_of_boolean_in(:attr, [true, false], null: true)
            stderr = capture(:stderr) do
              expect(record).to ensure_inclusion_of(:attr).in_array([true, false])
            end
            expect(stderr.gsub(/\n+/, ' ')).
              to include('You are using `ensure_inclusion_of` to assert that a boolean column allows boolean values and disallows non-boolean ones')
          end
        end

        context 'when ensuring inclusion of nil' do
          it "doesn't raise an error" do
            record = validating_inclusion_of_boolean_in(:attr, [nil], null: true)
            capture(:stderr) do
              expect(record).to ensure_inclusion_of(:attr).in_array([nil])
            end
          end

          it 'prints a warning' do
            record = validating_inclusion_of_boolean_in(:attr, [nil], null: true)
            stderr = capture(:stderr) do
              expect(record).to ensure_inclusion_of(:attr).in_array([nil])
            end
            expect(stderr.gsub(/\n+/, ' ')).
              to include('You are using `ensure_inclusion_of` to assert that a boolean column allows nil')
          end
        end
      end

      context 'which is non-nullable' do
        context 'when ensuring inclusion of true' do
          it "doesn't raise an error" do
            record = validating_inclusion_of_boolean_in(:attr, [true], null: false)
            expect(record).to ensure_inclusion_of(:attr).in_array([true])
          end
        end

        context 'when ensuring inclusion of false' do
          it "doesn't raise an error" do
            record = validating_inclusion_of_boolean_in(:attr, [false], null: false)
            expect(record).to ensure_inclusion_of(:attr).in_array([false])
          end
        end

        context 'when ensuring inclusion of true and false' do
          it "doesn't raise an error" do
            record = validating_inclusion_of_boolean_in(:attr, [true, false], null: false)
            capture(:stderr) do
              expect(record).to ensure_inclusion_of(:attr).in_array([true, false])
            end
          end

          it 'prints a warning' do
            record = validating_inclusion_of_boolean_in(:attr, [true, false], null: false)
            stderr = capture(:stderr) do
              expect(record).to ensure_inclusion_of(:attr).in_array([true, false])
            end
            expect(stderr.gsub(/\n+/, ' ')).
              to include('You are using `ensure_inclusion_of` to assert that a boolean column allows boolean values and disallows non-boolean ones')
          end
        end

        context 'when ensuring inclusion of nil' do
          it 'raises a specific error' do
            record = validating_inclusion_of_boolean_in(:attr, [nil], null: false)
            error_class = Shoulda::Matchers::ActiveModel::NonNullableBooleanError
            expect {
              expect(record).to ensure_inclusion_of(:attr).in_array([nil])
            }.to raise_error(error_class)
          end
        end
      end
    end
  end

  context 'for database attributes' do
  end

  def validating_inclusion(options)
    define_model(:example, attr: :string) do
      validates_inclusion_of :attr, options
    end.new
  end

  def validating_inclusion_of_boolean_in(attribute, values, options = {})
    null = options.fetch(:null, true)
    column_options = { type: :boolean, options: { null: null } }
    define_model(:example, attribute => column_options) do
      validates_inclusion_of attribute, in: values
    end.new
  end
=end
end
