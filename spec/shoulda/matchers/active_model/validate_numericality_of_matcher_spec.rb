require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateNumericalityOfMatcher do
  context '#description' do
    it 'states that it allows only numeric values' do
      matcher.description.should == 'only allow numeric values for attr'
    end
  end

  context 'with a model with a numericality validation' do
    it 'accepts' do
      validating_numericality.should matcher
    end

    it 'does not override the default message with a blank' do
      validating_numericality.should matcher.with_message(nil)
    end
  end

  context 'with a model without a numericality validation' do
    it 'rejects' do
      define_model(:example, :attr => :string).new.should_not matcher
    end

    it 'rejects with the ActiveRecord :not_an_integer message' do
      the_matcher = matcher.only_integer

      the_matcher.matches?(define_model(:example, :attr => :string).new)

      the_matcher.failure_message_for_should.should include 'Expected errors to include "must be an integer"'
    end
  end

  context 'with the only_integer option' do
    it 'allows integer values for that attribute' do
      validating_numericality(:only_integer => true).should matcher.only_integer
    end

    it 'rejects when the model does not enforce integer values' do
      validating_numericality.should_not matcher.only_integer
    end

    it 'rejects with the ActiveRecord :not_an_integer message' do
      the_matcher = matcher.only_integer

      the_matcher.matches?(validating_numericality)

      the_matcher.failure_message_for_should.should include 'Expected errors to include "must be an integer"'
    end
  end

  context 'with a custom validation message' do
    it 'accepts when the messages match' do
      validating_numericality(:message => 'custom').
        should matcher.with_message(/custom/)
    end

    it 'rejects when the messages do not match' do
      validating_numericality(:message => 'custom').
        should_not matcher.with_message(/wrong/)
    end
  end

  def validating_numericality(options = {})
    define_model :example, :attr => :string do
      validates_numericality_of :attr, options
    end.new
  end

  def matcher
    validate_numericality_of(:attr)
  end
end
