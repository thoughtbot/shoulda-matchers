require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateNumericalityOfMatcher do
  context '#description' do
    it 'states that it allows only numeric values' do
      expect(matcher.description).to eq 'only allow numeric values for attr'
    end
  end

  context 'with a model with a numericality validation' do
    it 'accepts' do
      expect(validating_numericality).to matcher
    end

    it 'does not override the default message with a blank' do
      expect(validating_numericality).to matcher.with_message(nil)
    end
  end

  context 'with a model without a numericality validation' do
    it 'rejects' do
      expect(define_model(:example, attr: :string).new).not_to matcher
    end

    it 'rejects with the ActiveRecord :not_a_number message' do
      the_matcher = matcher

      the_matcher.matches?(define_model(:example, attr: :string).new)

      expect(the_matcher.failure_message_when_negated).to include 'Did not expect errors to include "is not a number"'
    end

    it 'rejects with the ActiveRecord :not_an_integer message' do
      the_matcher = matcher.only_integer

      the_matcher.matches?(define_model(:example, attr: :string).new)

      expect(the_matcher.failure_message).to include 'Expected errors to include "must be an integer"'
    end

    it 'rejects with the ActiveRecord :odd message' do
      the_matcher = matcher.odd

      the_matcher.matches?(define_model(:example, attr: :string).new)

      expect(the_matcher.failure_message).to include 'Expected errors to include "must be odd"'
    end

    it 'rejects with the ActiveRecord :even message' do
      the_matcher = matcher.even

      the_matcher.matches?(define_model(:example, attr: :string).new)

      expect(the_matcher.failure_message).to include 'Expected errors to include "must be even"'
    end
  end

  context 'with the only_integer option' do
    it 'allows integer values for that attribute' do
      expect(validating_numericality(only_integer: true)).to matcher.only_integer
    end

    it 'rejects when the model does not enforce integer values' do
      expect(validating_numericality).not_to matcher.only_integer
    end

    it 'rejects with the ActiveRecord :not_an_integer message' do
      the_matcher = matcher.only_integer

      the_matcher.matches?(validating_numericality)

      expect(the_matcher.failure_message).to include 'Expected errors to include "must be an integer"'
    end
  end

  context 'with the odd option' do
    it 'allows odd number values for that attribute' do
      expect(validating_numericality(odd: true)).to matcher.odd
    end

    it 'rejects when the model does not enforce odd number values' do
      expect(validating_numericality).not_to matcher.odd
    end

    it 'rejects with the ActiveRecord :odd message' do
      the_matcher = matcher.odd

      the_matcher.matches?(validating_numericality)

      expect(the_matcher.failure_message).to include 'Expected errors to include "must be odd"'
    end
  end

  context 'with the even option' do
    it 'allows even number values for that attribute' do
      expect(validating_numericality(even: true)).to matcher.even
    end

    it 'rejects when the model does not enforce even number values' do
      expect(validating_numericality).not_to matcher.even
    end

    it 'rejects with the ActiveRecord :even message' do
      the_matcher = matcher.even

      the_matcher.matches?(validating_numericality)

      expect(the_matcher.failure_message).to include 'Expected errors to include "must be even"'
    end
  end

  context 'with a custom validation message' do
    it 'accepts when the messages match' do
      expect(validating_numericality(message: 'custom')).
        to matcher.with_message(/custom/)
    end

    it 'rejects when the messages do not match' do
      expect(validating_numericality(message: 'custom')).
        not_to matcher.with_message(/wrong/)
    end
  end

  context 'when the subject is stubbed' do
    it 'retains stubs on submatchers' do
      subject = define_model :example, attr: :string do
        validates_numericality_of :attr, odd: true
        before_validation :set_attr!
        def set_attr!; self.attr = 5 end
      end.new

      subject.stubs(:set_attr!)
      expect(subject).to matcher.odd
    end
  end

  def validating_numericality(options = {})
    define_model :example, attr: :string do
      validates_numericality_of :attr, options
    end.new
  end

  def matcher
    validate_numericality_of(:attr)
  end
end
