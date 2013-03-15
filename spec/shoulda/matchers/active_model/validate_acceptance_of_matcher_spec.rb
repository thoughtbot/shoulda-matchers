require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateAcceptanceOfMatcher do
  context 'a model with an acceptance validation' do
    it 'accepts when the attributes match' do
      validating_acceptance.should matcher
    end

    it 'does not overwrite the default message with nil' do
      validating_acceptance.should matcher.with_message(nil)
    end
  end

  context 'a model without an acceptance validation' do
    it 'rejects' do
      define_model(:example, :attr => :string).new.should_not matcher
    end
  end

  context 'an attribute which must be accepted with a custom message' do
    it 'accepts when the message matches' do
      validating_acceptance(:message => 'custom').
        should matcher.with_message(/custom/)
    end

    it 'rejects when the message does not match' do
      validating_acceptance(:message => 'custom').
        should_not matcher.with_message(/wrong/)
    end
  end

  def matcher
    validate_acceptance_of(:attr)
  end

  def validating_acceptance(options = {})
    define_model(:example, :attr => :string) do
      validates_acceptance_of :attr, options
    end.new
  end
end
