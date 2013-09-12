require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ComparisonMatcher do
  include ActiveModelHelpers::NumericalityHelpers

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

  context 'is_equal_to' do
    it { instance_with_validations(:equal_to => 0).should matcher.is_equal_to(0) }
    it { instance_without_validations.should_not matcher.is_equal_to(0) }
  end
end
