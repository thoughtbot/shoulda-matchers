require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::OddEvenNumberMatcher do
  context 'given an attribute that only allows odd number values' do
    it 'matches' do
      validating_odd_number.should new_odd_matcher
    end

    it 'returns itself when given a message' do
      matcher = new_odd_matcher
      matcher.with_message('some message').should == matcher
    end
  end

  context 'given an attribute that only allows even number values' do
    it 'matches' do
      validating_even_number.should new_even_matcher
    end

    it 'returns itself when given a message' do
      matcher = new_even_matcher
      matcher.with_message('some message').should == matcher
    end
  end

  context 'given an attribute that only allows odd number values with a custom validation message' do
    it 'only accepts odd number values for that attribute with that message' do
      validating_odd_number(:message => 'custom').should new_odd_matcher.with_message(/custom/)
    end

    it 'rejects odd number values for that attribute with another message' do
      validating_odd_number(:message => 'custom').should_not new_odd_matcher.with_message(/wrong/)
    end
  end

  context 'given an attribute that only allows even number values with a custom validation message' do
    it 'only accepts even number values for that attribute with that message' do
      validating_even_number(:message => 'custom').should new_even_matcher.with_message(/custom/)
    end

    it 'rejects even number values for that attribute with another message' do
      validating_even_number(:message => 'custom').should_not new_even_matcher.with_message(/wrong/)
    end
  end

  context 'when the model does not have an odd validation' do
    it 'does not match' do
      define_model(:example, :attr => :string).new.should_not new_odd_matcher
    end

    it 'fails with the ActiveRecord :odd message' do
      matcher = new_odd_matcher

      matcher.matches?(define_model(:example, :attr => :string).new)

      matcher.failure_message_for_should.should include 'Expected errors to include "must be odd"'
    end
  end

  context 'when the model does not have an even validation' do
    it 'does not match' do
      define_model(:example, :attr => :string).new.should_not new_even_matcher
    end

    it 'fails with the ActiveRecord :even message' do
      matcher = new_even_matcher

      matcher.matches?(define_model(:example, :attr => :string).new)

      matcher.failure_message_for_should.should include 'Expected errors to include "must be even"'
    end
  end

  def new_odd_matcher
    described_class.new(:attr, :odd => true)
  end

  def new_even_matcher
    described_class.new(:attr, :even => true)
  end

  def validating_odd_number(options = {})
    define_model :example, :attr => :string do
      validates_numericality_of :attr, { :odd => true }.merge(options)
    end.new
  end

   def validating_even_number(options = {})
    define_model :example, :attr => :string do
      validates_numericality_of :attr, { :even => true }.merge(options)
    end.new
  end
end
