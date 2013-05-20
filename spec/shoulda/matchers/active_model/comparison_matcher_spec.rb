require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ComparisonMatcher do
  context 'with a model with a greater than validation' do
    subject{ comparison_instance(:greater_than => 2) }
    it { should matcher.is_greater_than(2) }
  end

  context 'with a model with a greater than or equal to validation' do
    subject { comparison_instance(:greater_than_or_equal_to => 2) }
    it { should matcher.is_greater_than_or_equal_to(2) }
  end

  context 'with a model with a less than validation' do
    subject { comparison_instance(:less_than => 2) }
    it { should matcher.is_less_than(2) }
  end

  context 'with a model with a less than or equal to validation' do
    subject { comparison_instance(:less_than_or_equal_to => 2) }
    it { should matcher.is_less_than_or_equal_to(2) }
  end

  def comparison_instance(options = {})
    define_model :example, :attr => :string do
      validates_numericality_of :attr, options
      attr_accessible :attr
    end.new
  end

  def matcher
    validate_numericality_of(:attr)#.send("is_#{match}", val)
  end
end
