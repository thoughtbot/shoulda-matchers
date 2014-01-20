require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::NumericalityMatchers::OddEvenNumberMatcher do
  it_behaves_like 'a numerical submatcher' do
    subject { described_class.new(:attr) }
  end

  context 'given an attribute that only allows odd number values' do
    it 'matches' do
      expect(validating_odd_number).to new_odd_matcher
    end

    it 'returns itself when given a message' do
      matcher = new_odd_matcher
      expect(matcher.with_message('some message')).to eq matcher
    end
  end

  context 'given an attribute that only allows even number values' do
    it 'matches' do
      expect(validating_even_number).to new_even_matcher
    end

    it 'returns itself when given a message' do
      matcher = new_even_matcher
      expect(matcher.with_message('some message')).to eq matcher
    end
  end

  context 'given an attribute that only allows odd number values with a custom validation message' do
    it 'only accepts odd number values for that attribute with that message' do
      expect(validating_odd_number(message: 'custom')).to new_odd_matcher.with_message(/custom/)
    end

    it 'rejects odd number values for that attribute with another message' do
      expect(validating_odd_number(message: 'custom')).not_to new_odd_matcher.with_message(/wrong/)
    end
  end

  context 'given an attribute that only allows even number values with a custom validation message' do
    it 'only accepts even number values for that attribute with that message' do
      expect(validating_even_number(message: 'custom')).to new_even_matcher.with_message(/custom/)
    end

    it 'rejects even number values for that attribute with another message' do
      expect(validating_even_number(message: 'custom')).not_to new_even_matcher.with_message(/wrong/)
    end
  end

  context 'when the model does not have an odd validation' do
    it 'does not match' do
      expect(define_model(:example, attr: :string).new).not_to new_odd_matcher
    end

    it 'fails with the ActiveRecord :odd message' do
      matcher = new_odd_matcher

      matcher.matches?(define_model(:example, attr: :string).new)

      expect(matcher.failure_message).to include 'Expected errors to include "must be odd"'
    end
  end

  context 'when the model does not have an even validation' do
    it 'does not match' do
      expect(define_model(:example, attr: :string).new).not_to new_even_matcher
    end

    it 'fails with the ActiveRecord :even message' do
      matcher = new_even_matcher

      matcher.matches?(define_model(:example, attr: :string).new)

      expect(matcher.failure_message).to include 'Expected errors to include "must be even"'
    end
  end

  def new_odd_matcher
    described_class.new(:attr, odd: true)
  end

  def new_even_matcher
    described_class.new(:attr, even: true)
  end

  def validating_odd_number(options = {})
    define_model :example, attr: :string do
      validates_numericality_of :attr, { odd: true }.merge(options)
    end.new
  end

  def validating_even_number(options = {})
    define_model :example, attr: :string do
      validates_numericality_of :attr, { even: true }.merge(options)
    end.new
  end
end
