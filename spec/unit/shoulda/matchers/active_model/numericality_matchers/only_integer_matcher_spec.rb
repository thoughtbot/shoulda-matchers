require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel::NumericalityMatchers::OnlyIntegerMatcher do
  subject { described_class.new(:attr) }

  it_behaves_like 'a numerical submatcher'
  it_behaves_like 'a numerical type submatcher'

  it 'allows integer types' do
    expect(subject.allowed_type).to eq 'integers'
  end

  describe '#diff_to_compare' do
    it { expect(subject.diff_to_compare).to eq 1 }
  end

  context 'given an attribute that only allows integer values' do
    it 'matches' do
      match = subject
      expect(validating_only_integer).to match
    end
  end

  context 'given an attribute that only allows integer values with a custom validation message' do
    it 'only accepts integer values for that attribute with that message' do
      expect(validating_only_integer(message: 'custom')).to subject.with_message(/custom/)
    end

    it 'rejects integer values for that attribute with another message' do
      expect(validating_only_integer(message: 'custom')).not_to subject.with_message(/wrong/)
    end
  end

  context 'when the model does not have an only_integer validation' do
    it 'does not match' do
      match = subject
      expect(not_validating_only_integer).not_to match
    end

    it 'fails with the ActiveRecord :not_an_integer message' do
      match = subject
      expect {
        expect(not_validating_only_integer).to match
      }.to fail_with_message_including('Expected errors to include "must be an integer"')
    end
  end

  context 'asserting strict validation when validating strictly' do
    it 'accepts' do
      expect(validating_only_integer(strict: true)).to subject.strict
    end
  end

  context 'asserting non-strict validation when validating strictly' do
    it 'rejects' do
      pending 'This needs to be fixed'
      expect(validating_only_integer(strict: true)).not_to subject
    end
  end

  context 'asserting strict validation when not validating strictly' do
    it 'rejects' do
      expect(validating_only_integer).not_to subject.strict
    end
  end

  context 'qualified with on and validating with on' do
    it 'accepts' do
      expect(validating_only_integer(on: :customizable)).
        to subject.on(:customizable)
    end
  end

  context 'qualified with on but not validating with on' do
    it 'accepts since the validation never considers a context' do
      expect(validating_only_integer).to subject.on(:customizable)
    end
  end

  context 'not qualified with on but validating with on' do
    it 'rejects since the validation never runs' do
      expect(validating_only_integer(on: :customizable)).
        not_to subject
    end
  end

  def validating_only_integer(options = {})
    define_model :example, attr: :string do
      validates_numericality_of :attr, { only_integer: true }.merge(options)
    end.new
  end

  def not_validating_only_integer
    define_model(:example, attr: :string).new
  end
end
