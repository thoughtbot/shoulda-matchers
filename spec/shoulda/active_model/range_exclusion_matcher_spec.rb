require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::RangeExclusionMatcher do
  context '#matches?' do
    it 'returns true when the range is correctly excluded'
    it 'returns false when the validation disallows a higher value'
    it 'returns false when the validation disallows a lower value'
  end
end
