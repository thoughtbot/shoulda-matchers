require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ContextMatcher do
  include ActiveModelHelpers::NumericalityHelpers

  context 'on' do
    it { instance_with_validations(:on => :customisable).should matcher.on(:customisable) }
    it { instance_without_validations.should_not matcher.on(:customisable) }
  end
end
