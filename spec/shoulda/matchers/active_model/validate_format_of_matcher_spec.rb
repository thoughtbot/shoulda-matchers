require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateFormatOfMatcher do
  context 'a model with a format validation' do
    it 'accepts when format matches ' do
      validating_format(:with => /^\d{5}$/).should matcher.with('12345')
    end

    it 'rejects blank with should_not' do
      validating_format(:with => /^\d{5}$/).should_not matcher.with(' ')
    end

    it 'rejects blank with not_with' do
      validating_format(:with => /^\d{5}$/).should matcher.not_with(' ')
    end

    it 'rejects nil' do
      validating_format(:with => /^\d{5}$/).should_not matcher.with(nil)
    end

    it 'rejects a non-matching format with should_not' do
      validating_format(:with => /^\d{5}$/).should_not matcher.with('1234a')
    end

    it 'rejects a non-matching format with not_with' do
      validating_format(:with => /^\d{5}$/).should matcher.not_with('1234a')
    end

    it 'raises an error if you try to call both with and not_with' do
      expect {
        validate_format_of(:attr).not_with('123456').with('12345')
      }.to raise_error(RuntimeError)
    end
  end

  context 'when allow_blank or allow_nil are set' do
    it 'is valid when attr is nil' do
      validating_format(:with => /abc/, :allow_nil => true).
        should matcher.with(nil)
    end

    it 'is valid when attr is blank' do
      validating_format(:with => /abc/, :allow_blank => true).
        should matcher.with(' ')
    end
  end

  context '#allow_blank' do
    it 'accepts when allow_blank matches' do
      validating_format(:with => /abc/, :allow_blank => true).
        should matcher.allow_blank
    end

    it 'rejects when allow_blank does not match' do
      validating_format(:with => /abc/, :allow_blank => false).
        should_not matcher.allow_blank
    end
  end

  context '#allow_nil' do
    it 'accepts when allow_nil matches' do
      validating_format(:with => /abc/, :allow_nil => true).
        should matcher.allow_nil
    end

    it 'rejects when allow_nil does not match' do
      validating_format(:with => /abc/, :allow_nil => false).
        should_not matcher.allow_nil
    end
  end

  def matcher
    validate_format_of(:attr)
  end
end
