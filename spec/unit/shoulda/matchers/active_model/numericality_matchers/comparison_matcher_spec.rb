require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel::NumericalityMatchers::ComparisonMatcher do
  subject { described_class.new(matcher, 0, :>) }

  it_behaves_like 'a numerical submatcher'

  shared_examples_for 'strict qualifier' do
    def validation_qualifier
      matcher_qualifier.to_s.gsub(/^is_/, '').to_sym
    end

    context 'asserting strict validation when validating strictly' do
      it 'accepts' do
        record = instance_with_validations(
          validation_qualifier => 1,
          strict: true
        )
        expect(record).to matcher.__send__(matcher_qualifier, 1).strict
      end
    end

    context 'asserting non-strict validation when validating strictly' do
      it 'rejects' do
        pending 'This needs to be fixed'
        record = instance_with_validations(
          validation_qualifier => 1,
          strict: true
        )
        expect(record).not_to matcher.__send__(matcher_qualifier, 1)
      end
    end

    context 'asserting strict validation when not validating strictly' do
      it 'rejects' do
        record = instance_with_validations(validation_qualifier => 1)
        expect(record).not_to matcher.__send__(matcher_qualifier, 1).strict
      end
    end
  end

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
    include_examples 'strict qualifier' do
      def matcher_qualifier
        :is_greater_than
      end
    end

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

  context 'is_greater_than_or_equal_to' do
    include_examples 'strict qualifier' do
      def matcher_qualifier
        :is_greater_than_or_equal_to
      end
    end

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

  context 'is_less_than' do
    include_examples 'strict qualifier' do
      def matcher_qualifier
        :is_less_than
      end
    end

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

  context 'is_less_than_or_equal_to' do
    include_examples 'strict qualifier' do
      def matcher_qualifier
        :is_less_than_or_equal_to
      end
    end

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
    include_examples 'strict qualifier' do
      def matcher_qualifier
        :is_equal_to
      end
    end

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

  context 'qualified with on and validating with on' do
    it 'accepts' do
      expect(instance_with_validations(on: :customizable)).
        to matcher.on(:customizable)
    end
  end

  context 'qualified with on but not validating with on' do
    it 'accepts since the validation never considers a context' do
      expect(instance_with_validations).to matcher.on(:customizable)
    end
  end

  context 'not qualified with on but validating with on' do
    it 'rejects since the validation never runs' do
      expect(instance_with_validations(on: :customizable)).
        not_to matcher
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

  def model_with_validations(options = {})
    define_model :example, attribute_name => :string do |model|
      model.validates_numericality_of(attribute_name, options)
      model.attr_accessible(attribute_name)
    end
  end

  def instance_with_validations(options = {})
    model_with_validations(options).new(attribute_name => '1')
  end

  def instance_without_validations
    define_model :example, attribute_name => :string do |model|
      model.attr_accessible(attribute_name)
    end.new
  end

  def attribute_name
    :attr
  end

  def matcher
    validate_numericality_of(:attr)
  end
end
