require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateExclusionOfMatcher, type: :model do
  context 'an attribute which must be excluded from a range' do
    it 'accepts ensuring the correct range' do
      expect(validating_exclusion(in: 2..5)).
        to validate_exclusion_of(:attr).in_range(2..5)
    end

    it 'rejects ensuring excluded value' do
      expect(validating_exclusion(in: 2..5)).
        not_to validate_exclusion_of(:attr).in_range(2..6)
    end

    it 'does not override the default message with a blank' do
      expect(validating_exclusion(in: 2..5)).
        to validate_exclusion_of(:attr).in_range(2..5).with_message(nil)
    end

    it_supports(
      'ignoring_interference_by_writer',
      tests: {
        reject_if_qualified_but_changing_value_interferes: {
          model_name: 'Example',
          attribute_name: :attr,
          changing_values_with: :next_value,
          expected_message: <<-MESSAGE.strip
Example did not properly validate that :attr lies outside the range ‹2›
to ‹5›.
  After setting :attr to ‹1› -- which was read back as ‹2› -- the
  matcher expected the Example to be valid, but it was invalid instead,
  producing these validation errors:

  * attr: ["is reserved"]

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
          MESSAGE
        },
      },
      model_creator: :active_model
    ) do
      def validation_matcher_scenario_args
        super.deep_merge(validation_options: { in: 2..5 })
      end

      def configure_validation_matcher(matcher)
        matcher.in_range(2..5)
      end
    end
  end

  context 'an attribute which must be excluded from a range with excluded end' do
    it 'accepts ensuring the correct range' do
      expect(validating_exclusion(in: 2...5)).
        to validate_exclusion_of(:attr).in_range(2...5)
    end

    it 'rejects ensuring excluded value' do
      expect(validating_exclusion(in: 2...5)).
        not_to validate_exclusion_of(:attr).in_range(2...4)
    end
  end

  context 'an attribute with a custom validation message' do
    it 'accepts ensuring the correct range' do
      expect(validating_exclusion(in: 2..4, message: 'not good')).
        to validate_exclusion_of(:attr).in_range(2..4).with_message(/not good/)
    end
  end

  context 'an attribute with custom range validations' do
    it 'accepts ensuring the correct range and messages' do
      model = custom_validation do
        if attr >= 2 && attr <= 5
          errors.add(:attr, 'should be out of this range')
        end
      end

      expect(model).to validate_exclusion_of(:attr).in_range(2..5).
        with_message(/should be out of this range/)

      model = custom_validation do
        if attr >= 2 && attr <= 4
          errors.add(:attr, 'should be out of this range')
        end
      end

      expect(model).to validate_exclusion_of(:attr).in_range(2...5).
        with_message(/should be out of this range/)
    end

    it 'has correct description' do
      matcher = validate_exclusion_of(:attr).in_range(1..10)

      expect(matcher.description).to eq(
        'validate that :attr lies outside the range ‹1› to ‹10›'
      )
    end
  end

  context 'an attribute which must be excluded from an array' do
    it 'accepts with correct array' do
      expect(validating_exclusion(in: %w(one two))).
        to validate_exclusion_of(:attr).in_array(%w(one two))
    end

    it 'rejects when only part of array matches' do
      expect(validating_exclusion(in: %w(one two))).
        not_to validate_exclusion_of(:attr).in_array(%w(one wrong_value))
    end

    it 'rejects when array does not match at all' do
      expect(validating_exclusion(in: %w(one two))).
        not_to validate_exclusion_of(:attr).in_array(%w(cat dog))
    end

    context 'when there is one value' do
      it 'has correct description' do
        expect(validate_exclusion_of(:attr).in_array([true]).description).
          to eq 'validate that :attr is not ‹true›'
      end
    end

    context 'when there are two values' do
      it 'has correct description' do
        matcher = validate_exclusion_of(:attr).in_array([true, 'dog'])

        expect(matcher.description).to eq(
          'validate that :attr is neither ‹true› nor ‹"dog"›'
        )
      end
    end

    context 'when there are three or more values' do
      it 'has correct description' do
        matcher = validate_exclusion_of(:attr).in_array([true, 'dog', 'cat'])

        expect(matcher.description).to eq(
          'validate that :attr is neither ‹true›, ‹"dog"›, nor ‹"cat"›'
        )
      end
    end

    it_supports(
      'ignoring_interference_by_writer',
      tests: {
        reject_if_qualified_but_changing_value_interferes: {
          model_name: 'Example',
          attribute_name: :attr,
          changing_values_with: :next_value,
          expected_message: <<-MESSAGE.strip
Example did not properly validate that :attr is neither ‹"one"› nor
‹"two"›.
  After setting :attr to ‹"one"› -- which was read back as ‹"onf"› --
  the matcher expected the Example to be invalid, but it was valid
  instead.

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
        MESSAGE
        },
      },
      model_creator: :active_model
    ) do
      def validation_matcher_scenario_args
        super.deep_merge(validation_options: { in: ['one', 'two'] })
      end

      def configure_validation_matcher(matcher)
        matcher.in_array(['one', 'two'])
      end
    end

    def define_model_validating_exclusion(options)
      options = options.dup
      column_type = options.delete(:column_type) { :string }
      super options.merge(column_type: column_type)
    end
  end

  def define_model_validating_exclusion(options)
    options = options.dup
    attribute_name = options.delete(:attribute_name) { :attr }
    column_type = options.delete(:column_type) { :integer }

    define_model(:example, attribute_name => column_type) do |model|
      model.validates_exclusion_of(attribute_name, options)
    end
  end

  def validating_exclusion(options)
    define_model_validating_exclusion(options).new
  end

  alias_method :build_record_validating_exclusion, :validating_exclusion

  def validation_matcher_scenario_args
    super.deep_merge(matcher_name: :validate_exclusion_of)
  end
end
