require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateConfirmationOfMatcher do
  context '#description' do
    it 'states that the confirmation must match its base attribute' do
      expect(matcher.description).to eq 'require attr_confirmation to match attr'
    end
  end

  context 'a model with a confirmation validation' do
    it 'accepts' do
      expect(validating_confirmation).to matcher
    end

    it 'does not override the default message with a blank' do
      expect(validating_confirmation).to matcher.with_message(nil)
    end
  end

  context 'a model without a confirmation validation' do
    it 'rejects' do
      expect(define_model(:example, attr: :string).new).not_to matcher
    end
  end

  context 'a confirmation validation with a custom message' do
    it 'accepts when the message matches' do
      expect(validating_confirmation(message: 'custom')).
        to matcher.with_message(/custom/)
    end

    it 'rejects when the messages do not match' do
      expect(validating_confirmation(message: 'custom')).
        not_to matcher.with_message(/wrong/)
    end
  end

  def matcher
    validate_confirmation_of(:attr)
  end

  def validating_confirmation(options = {})
    define_model(:example, attr: :string) do
      validates_confirmation_of :attr, options
    end.new
  end
end
