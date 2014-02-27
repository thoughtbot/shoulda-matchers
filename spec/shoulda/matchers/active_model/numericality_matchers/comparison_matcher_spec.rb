require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::NumericalityMatchers::ComparisonMatcher do
  subject { described_class.new(matcher, 0, :>) }

  it_behaves_like 'a numerical submatcher'

  context 'when initialized without correct numerical matcher' do
    it 'raises an argument error' do
      fake_matcher = matcher
      class << fake_matcher
        undef_method :diff_to_compare
      end
      expect do
        described_class.new(fake_matcher, 0, :>)
      end.to raise_error ArgumentError
    end
  end

  context 'is_greater_than' do
    it do
      expect(instance_with_validations(greater_than: 2))
        .to matcher.is_greater_than(2)
    end

    it do
      expect(instance_with_validations(greater_than: 1.5))
        .not_to matcher.is_greater_than(2)
    end

    it do
      expect(instance_with_validations(greater_than: 2.5))
        .not_to matcher.is_greater_than(2)
    end

    it do
      expect(instance_without_validations).not_to matcher.is_greater_than(2)
    end
  end

  context 'greater_than_or_equal_to' do
    it do
      expect(instance_with_validations(greater_than_or_equal_to: 2))
        .to matcher.is_greater_than_or_equal_to(2)
    end

    it do
      expect(instance_with_validations(greater_than_or_equal_to: 1.5))
        .not_to matcher.is_greater_than_or_equal_to(2)
    end

    it do
      expect(instance_with_validations(greater_than_or_equal_to: 2.5))
        .not_to matcher.is_greater_than_or_equal_to(2)
    end

    it do
      expect(instance_without_validations)
        .not_to matcher.is_greater_than_or_equal_to(2)
    end
  end

  context 'less_than' do
    it do
      expect(instance_with_validations(less_than: 2))
        .to matcher.is_less_than(2)
    end

    it do
      expect(instance_with_validations(less_than: 1.5))
        .not_to matcher.is_less_than(2)
    end

    it do
      expect(instance_with_validations(less_than: 2.5))
        .not_to matcher.is_less_than(2)
    end

    it do
      expect(instance_without_validations)
        .not_to matcher.is_less_than(2)
    end
  end

  context 'less_than_or_equal_to' do
    it do
      expect(instance_with_validations(less_than_or_equal_to: 2))
        .to matcher.is_less_than_or_equal_to(2)
    end

    it do
      expect(instance_with_validations(less_than_or_equal_to: 1.5))
        .not_to matcher.is_less_than_or_equal_to(2)
    end

    it do
      expect(instance_with_validations(less_than_or_equal_to: 2.5))
        .not_to matcher.is_less_than_or_equal_to(2)
    end

    it do
      expect(instance_without_validations)
        .not_to matcher.is_less_than_or_equal_to(2)
    end
  end

  context 'is_equal_to' do
    it do
      expect(instance_with_validations(equal_to: 0))
        .to matcher.is_equal_to(0)
    end

    it do
      expect(instance_with_validations(equal_to: -0.5))
        .not_to matcher.is_equal_to(0)
    end

    it do
      expect(instance_with_validations(equal_to: 0.5))
        .not_to matcher.is_equal_to(0)
    end

    it do
      expect(instance_without_validations)
        .not_to matcher.is_equal_to(0)
    end
  end

  context 'with_message' do
    it 'verifies the message for the validation' do
      instance = instance_with_validations(equal_to: 0, message: 'Must be zero')
      expect(instance).to matcher.is_equal_to(0).with_message('Must be zero')
    end
  end

  describe '#comparison_description' do
    [{ operator: :>, value: 0, expectation: 'greater than 0' },
     { operator: :>=, value: -1.0, expectation: 'greater than or equal to -1.0' },
     { operator: :==, value: 2.2, expectation: 'equal to 2.2' },
     { operator: :<, value: -3, expectation: 'less than -3' },
     { operator: :<=, value: 4, expectation: 'less than or equal to 4' },
    ].each do |h|
      context "with :#{h[:operator]} as operator and #{h[:value]} as value" do
        subject do
          described_class.new(matcher, h[:value], h[:operator])
            .comparison_description
        end
        it { should eq h[:expectation] }
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
