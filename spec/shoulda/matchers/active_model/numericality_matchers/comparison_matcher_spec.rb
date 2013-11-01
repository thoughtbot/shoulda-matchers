require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::NumericalityMatchers::ComparisonMatcher do
  it_behaves_like 'a numerical submatcher' do
    subject { described_class.new(0, :>) }
  end

  context 'is_greater_than' do
    it { instance_with_validations(greater_than: 2).should matcher.is_greater_than(2) }
    it { instance_without_validations.should_not matcher.is_greater_than(2) }
  end

  context 'greater_than_or_equal_to' do
    it { instance_with_validations(greater_than_or_equal_to: 2).should matcher.is_greater_than_or_equal_to(2) }
    it { instance_without_validations.should_not matcher.is_greater_than_or_equal_to(2) }
  end

  context 'less_than' do
    it { instance_with_validations(less_than: 2).should matcher.is_less_than(2) }
    it { instance_without_validations.should_not matcher.is_less_than(2) }
  end

  context 'less_than_or_equal_to' do
    it { instance_with_validations(less_than_or_equal_to: 2).should matcher.is_less_than_or_equal_to(2) }
    it { instance_without_validations.should_not matcher.is_less_than_or_equal_to(2) }
  end

  context 'is_equal_to' do
    it { instance_with_validations(equal_to: 0).should matcher.is_equal_to(0) }
    it { instance_without_validations.should_not matcher.is_equal_to(0) }
  end

  context 'with_message' do
    it 'verifies the message for the validation' do
      instance = instance_with_validations(equal_to: 0, message: 'Must be zero')
      instance.should matcher.is_equal_to(0).with_message('Must be zero')
    end
  end

  def instance_with_validations(options = {})
    define_model :example, attr: :string do
      validates_numericality_of :attr, options
      attr_accessible :attr
    end.new
  end

  def instance_without_validations
    define_model :example, attr: :string do
      attr_accessible :attr
    end.new
  end

  def matcher
    validate_numericality_of(:attr)
  end
end
