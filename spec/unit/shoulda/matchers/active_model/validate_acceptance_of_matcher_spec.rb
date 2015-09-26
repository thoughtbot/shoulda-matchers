require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateAcceptanceOfMatcher, type: :model do
  context 'a model with an acceptance validation' do
    it 'accepts when the attributes match' do
      expect(record_validating_acceptance).to matcher
    end

    it 'does not overwrite the default message with nil' do
      expect(record_validating_acceptance).to matcher.with_message(nil)
    end
  end

  context 'a model without an acceptance validation' do
    it 'rejects' do
      expect(record_validating_nothing).not_to matcher
    end
  end

  context 'an attribute which must be accepted with a custom message' do
    it 'accepts when the message matches' do
      expect(record_validating_acceptance(message: 'custom')).
        to matcher.with_message(/custom/)
    end

    it 'rejects when the message does not match' do
      expect(record_validating_acceptance(message: 'custom')).
        not_to matcher.with_message(/wrong/)
    end
  end

  def matcher
    validate_acceptance_of(:attr)
  end

  def model_validating_nothing(&block)
    define_active_model_class(:example, accessors: [:attr], &block)
  end

  def record_validating_nothing
    model_validating_nothing.new
  end

  def model_validating_acceptance(options = {})
    model_validating_nothing do
      validates_acceptance_of :attr, options
    end
  end

  def record_validating_acceptance(options = {})
    model_validating_acceptance(options).new
  end
end
