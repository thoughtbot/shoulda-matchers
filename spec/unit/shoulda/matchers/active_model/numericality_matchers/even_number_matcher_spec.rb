require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::NumericalityMatchers::EvenNumberMatcher  do
  subject { described_class.new(:attr) }

  it_behaves_like 'a numerical submatcher'
  it_behaves_like 'a numerical type submatcher'

  it 'allows even number' do
    expect(subject.allowed_type).to eq 'even numbers'
  end

  describe '#diff_to_compare' do
    it { expect(subject.diff_to_compare).to eq 2 }
  end

  context 'when the model has an even validation' do
    it 'matches' do
      match = subject
      expect(validating_even_number).to match
    end
  end

  context 'when the model does not have an even validation' do
    it 'does not match' do
      match = subject
      expect(not_validating_even_number).not_to match
    end

    it 'fails with the ActiveRecord :even message' do
      match = subject
      expect {
        expect(not_validating_even_number).to match
      }.to fail_with_message_including('Expected errors to include "must be even"')
    end
  end

  context 'with custom validation message' do
    it 'only accepts even number values for that attribute with that message' do
      expect(validating_even_number(message: 'custom')).to subject.with_message(/custom/)
    end

    it 'fails even number values for that attribute with another message' do
      expect(validating_even_number(message: 'custom')).not_to subject.with_message(/wrong/)
    end
  end


  def validating_even_number(options = {})
    define_model :example, attr: :string do
      validates_numericality_of :attr, { even: true }.merge(options)
    end.new
  end

  def not_validating_even_number
    define_model(:example, attr: :string).new
  end

end