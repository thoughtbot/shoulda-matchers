require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ComparisonMatcher do
  context 'is_greater_than' do
    it { instance_with_validations(:greater_than => 2).should matcher.is_greater_than(2) }
    it { instance_without_validations.should_not matcher.is_greater_than(2) }
  end

  context 'greater_than_or_equal_to' do
    it { instance_with_validations(:greater_than_or_equal_to => 2).should matcher.is_greater_than_or_equal_to(2) }
    it { instance_without_validations.should_not matcher.is_greater_than_or_equal_to(2) }
  end

  context 'less_than' do
    it { instance_with_validations(:less_than => 2).should matcher.is_less_than(2) }
    it { instance_without_validations.should_not matcher.is_less_than(2) }
  end

  context 'less_than_or_equal_to' do
    it { instance_with_validations(:less_than_or_equal_to => 2).should matcher.is_less_than_or_equal_to(2) }
    it { instance_without_validations.should_not matcher.is_less_than_or_equal_to(2) }
  end

  def instance_with_validations(options = {})
    define_model :example, :attr => :string do
      validates_numericality_of :attr, options
      attr_accessible :attr
    end.new
  end

  def instance_without_validations
    define_model :example, :attr => :string do
      attr_accessible :attr
    end.new
  end

  def matcher
    validate_numericality_of(:attr)
  end
end
