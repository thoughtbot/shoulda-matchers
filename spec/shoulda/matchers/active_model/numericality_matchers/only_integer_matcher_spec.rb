require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::NumericalityMatchers::OnlyIntegerMatcher do
  it_behaves_like 'a numerical submatcher' do
    subject { described_class.new(:attr) }
  end

  context 'given an attribute that only allows integer values' do
    it 'matches' do
      expect(validating_only_integer).to new_matcher
    end

    it 'allows integer types' do
      expect(new_matcher.allowed_types).to eq 'integer'
    end

    it 'returns itself when given a message' do
      matcher = new_matcher
      expect(matcher.with_message('some message')).to eq matcher
    end
  end

  context 'given an attribute that only allows integer values with a custom validation message' do
    it 'only accepts integer values for that attribute with that message' do
      expect(validating_only_integer(message: 'custom')).to new_matcher.with_message(/custom/)
    end

    it 'rejects integer values for that attribute with another message' do
      expect(validating_only_integer(message: 'custom')).not_to new_matcher.with_message(/wrong/)
    end
  end

  context 'when the model does not have an only_integer validation' do
    it 'does not match' do
      expect(define_model(:example, attr: :string).new).not_to new_matcher
    end

    it 'fails with the ActiveRecord :not_an_integer message' do
      matcher = new_matcher

      matcher.matches?(define_model(:example, attr: :string).new)

      expect(matcher.failure_message).to include 'Expected errors to include "must be an integer"'
    end
  end

  def new_matcher
    described_class.new(:attr)
  end

  def validating_only_integer(options = {})
    define_model :example, attr: :string do
      validates_numericality_of :attr, { only_integer: true }.merge(options)
    end.new
  end
end
