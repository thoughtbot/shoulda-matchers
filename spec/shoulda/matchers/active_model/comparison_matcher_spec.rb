require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ComparisonMatcher do
  subject { comparison_instance }
  context 'with a model with a greater than validation' do
    it 'match accordingly' do
      subject.attr = 3
      subject.should matcher(:greater_than, 2)
      subject.attr = 2
      subject.should_not matcher(:greater_than, 2)
      subject.attr = 1
      subject.should_not matcher(:greater_than, 2)
    end
  end

  context 'with a model with a greater than or equal to validation' do
    it 'match accordingly' do
      subject.attr = 3
      subject.should matcher(:greater_than_or_equal_to, 2)
      subject.attr = 2
      subject.should matcher(:greater_than_or_equal_to, 2)
      subject.attr = 1
      subject.should_not matcher(:greater_than_or_equal_to, 2)
    end
  end

  context 'with a model with a less than validation' do
    it 'match accordingly' do
      subject.attr = 3
      subject.should_not matcher(:less_than, 2)
      subject.attr = 2
      subject.should_not matcher(:less_than, 2)
      subject.attr = 1
      subject.should matcher(:less_than, 2)
    end
  end

  context 'with a model with a less than or equal to validation' do
    it 'match accordingly' do
      subject.attr = 3
      subject.should_not matcher(:less_than_or_equal_to, 2)
      subject.attr = 2
      subject.should matcher(:less_than_or_equal_to, 2)
      subject.attr = 1
      subject.should matcher(:less_than_or_equal_to, 2)
    end
  end

  def comparison_instance(options = {})
    define_model :example, :attr => :string do
      validates_numericality_of :attr, options
    end.new
  end

  def matcher(match, val)
    validate_numericality_of(:attr).send("is_#{match}", val)
  end
end
