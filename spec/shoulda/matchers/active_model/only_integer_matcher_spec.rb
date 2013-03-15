require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::OnlyIntegerMatcher do
  context 'given an attribute that only allows integer values' do
    it 'matches' do
      only_integer.should new_matcher
    end

    it 'allows integer types' do
      new_matcher.allowed_types.should == 'integer'
    end

    it 'returns itself when given a message' do
      matcher = new_matcher
      matcher.with_message('some message').should == matcher
    end
  end

  context 'given an attribute that only allows integer values with a custom validation message' do
    it 'only accepts integer values for that attribute with that message' do
      only_integer(:message => 'custom').should new_matcher.with_message(/custom/)
    end

    it 'rejects integer values for that attribute with another message' do
      only_integer(:message => 'custom').should_not new_matcher.with_message(/wrong/)
    end
  end

  context 'when the model does not have an only_integer validation' do
    it 'does not match' do
      define_model(:example, :attr => :string).new.should_not new_matcher
    end

    it 'fails with the ActiveRecord :not_an_integer message' do
      matcher = new_matcher

      matcher.matches?(define_model(:example, :attr => :string).new)

      matcher.failure_message_for_should.should include 'Expected errors to include "must be an integer"'
    end
  end

  def new_matcher
    described_class.new(:attr)
  end

  def only_integer(options = {})
    define_model :example, :attr => :string do
      validates_numericality_of :attr, { :only_integer => true }.merge(options)
    end.new
  end
end
