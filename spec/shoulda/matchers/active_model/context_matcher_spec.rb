require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ContextMatcher do
  context 'on' do
    it { validating_something_in_context(:on => :customisable).should matcher.on(:customisable) }
    it { validating_nothing.should_not matcher.on(:customisable) }
  end

  def validating_something_in_context(options = {})
    define_model :example, :attr => :string do
      validates_numericality_of :attr, options
      attr_accessible :attr
    end.new
  end

  def validating_nothing
    define_model :example, :attr => :string do
      attr_accessible :attr
    end.new
  end

  def matcher
    validate_numericality_of(:attr)
  end
end
