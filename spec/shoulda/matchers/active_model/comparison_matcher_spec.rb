require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ComparisonMatcher do
  context 'with a model with a greater than validation' do
    it 'match accordingly' do
      comparison_instance(3).should matcher(:greater_than, 2)
      comparison_instance(2).should_not matcher(:greater_than, 2)
      comparison_instance(1).should_not matcher(:greater_than, 2)
    end
  end

  context 'with a model with a greater than or equal to validation' do
    it 'match accordingly' do
      comparison_instance(3).should matcher(:greater_than_or_equal_to, 2)
      comparison_instance(2).should matcher(:greater_than_or_equal_to, 2)
      comparison_instance(1).should_not matcher(:greater_than_or_equal_to, 2)
    end
  end

  context 'with a model with a less than validation' do
    it 'match accordingly' do
      comparison_instance(3).should_not matcher(:less_than, 2)
      comparison_instance(2).should_not matcher(:less_than, 2)
      comparison_instance(1).should matcher(:less_than, 2)
    end
  end

  context 'with a model with a less than or equal to validation' do
    it 'match accordingly' do
      comparison_instance(3).should_not matcher(:less_than_or_equal_to, 2)
      comparison_instance(2).should matcher(:less_than_or_equal_to, 2)
      comparison_instance(1).should matcher(:less_than_or_equal_to, 2)
    end
  end

  def comparison_instance(attr, options = {})
    define_model :example, :attr => :string do
      validates_numericality_of :attr, options
      attr_accessible :attr
    end.new(:attr => attr)
  end

  def matcher(match, val)
    validate_numericality_of(:attr).send("is_#{match}", val)
  end
end
