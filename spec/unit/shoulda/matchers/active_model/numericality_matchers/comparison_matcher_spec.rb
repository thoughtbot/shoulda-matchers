require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel::NumericalityMatchers::ComparisonMatcher do
  it_behaves_like 'a numerical submatcher' do
    subject { build_matcher }
  end

  shared_examples_for 'strict qualifier' do
    context 'asserting strict validation when validating strictly' do
      it 'accepts' do
        record = instance_with_validations(
          validation_qualifier => 1,
          strict: true
        )
        matcher = build_matcher(operator: operator, value: 1).strict
        expect(record).to matcher
      end
    end

    context 'asserting non-strict validation when validating strictly' do
      it 'rejects' do
        pending 'This needs to be fixed'
        record = instance_with_validations(
          validation_qualifier => 1,
          strict: true
        )
        matcher = build_matcher(operator: operator, value: 1)
        expect(record).not_to matcher
      end
    end

    context 'asserting strict validation when not validating strictly' do
      it 'rejects' do
        record = instance_with_validations(validation_qualifier => 1)
        matcher = build_matcher(operator: operator, value: 1).strict
        expect(record).not_to matcher
      end
    end
  end

  context 'when initialized without correct numerical matcher' do
    it 'raises an ArgumentError' do
      numericality_matcher = double
      expect { described_class.new(numericality_matcher, 0, :>) }.
        to raise_error(ArgumentError)
    end
  end

  describe 'is_greater_than' do
    include_examples 'strict qualifier'

    it do
      record = instance_with_validations(greater_than: 1.5)
      matcher = build_matcher(operator: :>, value: 2)
      expect(record).not_to matcher
    end

    it do
      record = instance_with_validations(greater_than: 2)
      matcher = build_matcher(operator: :>, value: 2)
      expect(record).to matcher
    end

    it do
      record = instance_with_validations(greater_than: 2.5)
      matcher = build_matcher(operator: :>, value: 2)
      expect(record).not_to matcher
    end

    it do
      record = instance_without_validations
      matcher = build_matcher(operator: :>, value: 2)
      expect(record).not_to matcher
    end

    def operator
      :>
    end

    def validation_qualifier
      :greater_than
    end
  end

  describe 'is_greater_than_or_equal_to' do
    include_examples 'strict qualifier'

    it do
      record = instance_with_validations(greater_than_or_equal_to: 1.5)
      matcher = build_matcher(operator: :>=, value: 2)
      expect(record).not_to matcher
    end

    it do
      record = instance_with_validations(greater_than_or_equal_to: 2)
      matcher = build_matcher(operator: :>=, value: 2)
      expect(record).to matcher
    end

    it do
      record = instance_with_validations(greater_than_or_equal_to: 2.5)
      matcher = build_matcher(operator: :>=, value: 2)
      expect(record).not_to matcher
    end

    it do
      record = instance_without_validations
      matcher = build_matcher(operator: :>=, value: 2)
      expect(record).not_to matcher
    end

    def operator
      :>=
    end

    def validation_qualifier
      :greater_than_or_equal_to
    end
  end

  describe 'is_less_than' do
    include_examples 'strict qualifier'

    it do
      record = instance_with_validations(less_than: 1.5)
      matcher = build_matcher(operator: :<, value: 2)
      expect(record).not_to matcher
    end

    it do
      record = instance_with_validations(less_than: 2)
      matcher = build_matcher(operator: :<, value: 2)
      expect(record).to matcher
    end

    it do
      record = instance_with_validations(less_than: 2.5)
      matcher = build_matcher(operator: :<, value: 2)
      expect(record).not_to matcher
    end

    it do
      record = instance_without_validations
      matcher = build_matcher(operator: :<, value: 2)
      expect(record).not_to matcher
    end

    def operator
      :<
    end

    def validation_qualifier
      :less_than
    end
  end

  describe 'is_less_than_or_equal_to' do
    include_examples 'strict qualifier'

    it do
      record = instance_with_validations(less_than_or_equal_to: 1.5)
      matcher = build_matcher(operator: :<=, value: 2)
      expect(record).not_to matcher
    end

    it do
      record = instance_with_validations(less_than_or_equal_to: 2)
      matcher = build_matcher(operator: :<=, value: 2)
      expect(record).to matcher
    end

    it do
      record = instance_with_validations(less_than_or_equal_to: 2.5)
      matcher = build_matcher(operator: :<=, value: 2)
      expect(record).not_to matcher
    end

    it do
      record = instance_without_validations
      matcher = build_matcher(operator: :<=, value: 2)
      expect(record).not_to matcher
    end

    def operator
      :<=
    end

    def validation_qualifier
      :less_than_or_equal_to
    end
  end

  describe 'is_equal_to' do
    include_examples 'strict qualifier'

    it do
      record = instance_with_validations(equal_to: 1.5)
      matcher = build_matcher(operator: :==, value: 2)
      expect(record).not_to matcher
    end

    it do
      record = instance_with_validations(equal_to: 2)
      matcher = build_matcher(operator: :==, value: 2)
      expect(record).to matcher
    end

    it do
      record = instance_with_validations(equal_to: 2.5)
      matcher = build_matcher(operator: :==, value: 2)
      expect(record).not_to matcher
    end

    it do
      record = instance_without_validations
      matcher = build_matcher(operator: :==, value: 2)
      expect(record).not_to matcher
    end

    def operator
      :==
    end

    def validation_qualifier
      :equal_to
    end
  end

  describe 'with_message' do
    it 'verifies the message for the validation' do
      instance = instance_with_validations(equal_to: 0, message: 'Must be zero')
      matcher = build_matcher.with_message('Must be zero')
      expect(instance).to matcher
    end
  end

  describe '#comparison_description' do
    tests = [
      { operator: :>, value: 0, expectation: 'greater than 0' },
      { operator: :>=, value: -1.0, expectation: 'greater than or equal to -1.0' },
      { operator: :==, value: 2.2, expectation: 'equal to 2.2' },
      { operator: :<, value: -3, expectation: 'less than -3' },
      { operator: :<=, value: 4, expectation: 'less than or equal to 4' },
    ]

    tests.each do |test|
      context "with :#{test[:operator]} as operator and #{test[:value]} as value" do
        it do
          matcher = build_matcher(operator: test[:operator], value: test[:value])
          expect(matcher.comparison_description).to eq test[:expectation]
        end
      end
    end
  end

  def model_with_validations(options = {})
    define_model :example, attribute_name => :string do |model|
      model.validates_numericality_of(attribute_name, options)
      model.attr_accessible(attribute_name)
    end
  end

  def instance_with_validations(options = {})
    model_with_validations(options).new(attribute_name => '1')
  end

  def model_without_validations
    define_model :example, attribute_name => :string do |model|
      model.attr_accessible(attribute_name)
    end
  end

  def instance_without_validations
    model_without_validations.new
  end

  def attribute_name
    :attr
  end

  def build_matcher(operator: :==, value: 0)
    described_class.new(numericality_matcher, value, operator).for(attribute_name)
  end

  def numericality_matcher
    double(diff_to_compare: 1)
  end
end
