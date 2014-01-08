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

  describe '#allowed_types' do
    [{ operator: :>, value: 0, ret_val: "'greater than 0'" },
     { operator: :>=, value: -1.0, ret_val: "'greater than or equal to -1.0'" },
     { operator: :==, value: 2.2, ret_val: "'equal to 2.2'" },
     { operator: :<, value: -3, ret_val: "'less than -3'" },
     { operator: :<=, value: 4, ret_val: "'less than or equal to 4'" },
    ].each do |h|
      context "with :#{h[:operator]} as operator and #{h[:value]} as value" do
        subject { described_class.new(h[:value], h[:operator]).allowed_types }
        it { should eq h[:ret_val] }
      end
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
