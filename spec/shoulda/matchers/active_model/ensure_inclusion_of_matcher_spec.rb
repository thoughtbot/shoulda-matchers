require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::EnsureInclusionOfMatcher do
  context 'with no validations' do
    it 'rejects an array which does not have a validator defined' do
      expect(define_model(:example, attr: :string).new).
        not_to ensure_inclusion_of(:attr).in_array(%w(Yes No))
    end
  end

  context 'with an integer column' do
    it 'can verify a zero in the array' do
      model = define_model(:example, attr: :integer) do
        validates_inclusion_of :attr, in: [0, 1, 2]
      end.new

      expect(model).to ensure_inclusion_of(:attr).in_array([0,1,2])
    end
  end

  context 'with an decimal column' do
    it 'can verify decimal values' do
      model = define_model(:example, attr: :decimal) do
        validates_inclusion_of :attr, in: [0.0, 0.1]
      end.new

      expect(model).to ensure_inclusion_of(:attr).in_array([0.0, 0.1])
    end
  end

  context 'with true/false values' do
    it 'can verify outside values to ensure the negative case' do
      expect(define_model(:example, attr: :string).new).
        not_to ensure_inclusion_of(:attr).in_array([true, false])
    end
  end

  context 'where we cannot determine a value outside the array' do
    it 'raises a custom exception' do
      model = define_model(:example, attr: :string).new

      arbitrary_string = described_class::ARBITRARY_OUTSIDE_STRING
      expect { expect(model).to ensure_inclusion_of(:attr).in_array([arbitrary_string]) }.to raise_error Shoulda::Matchers::ActiveModel::CouldNotDetermineValueOutsideOfArray
    end
  end

  context 'an attribute which must be included in a range' do
    it 'accepts ensuring the correct range' do
      expect(validating_inclusion(in: 2..5)).
        to ensure_inclusion_of(:attr).in_range(2..5)
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
end
