require 'spec_helper'

describe Shoulda::Matchers::ActiveModel do
  describe '#ensure_exclusion_of' do
    it 'is aliased to #validate_exclusion_of' do
      expect(method(:ensure_exclusion_of)).to eq(method(:validate_exclusion_of))
    end
  end
end

describe Shoulda::Matchers::ActiveModel::ValidateExclusionOfMatcher do
  context 'an attribute which must be excluded from a range' do
    it 'accepts ensuring the correct range' do
      expect(validating_exclusion(in: 2..5)).
        to validate_exclusion_of(:attr).in_range(2..5)
    end

    it 'rejects ensuring excluded value' do
      expect(validating_exclusion(in: 2..5)).
        not_to validate_exclusion_of(:attr).in_range(2..6)
    end

    it 'does not override the default message with a blank' do
      expect(validating_exclusion(in: 2..5)).
        to validate_exclusion_of(:attr).in_range(2..5).with_message(nil)
    end
  end

  context 'an attribute which must be excluded from a range with excluded end' do
    it 'accepts ensuring the correct range' do
      expect(validating_exclusion(in: 2...5)).
        to validate_exclusion_of(:attr).in_range(2...5)
    end

    it 'rejects ensuring excluded value' do
      expect(validating_exclusion(in: 2...5)).
        not_to validate_exclusion_of(:attr).in_range(2...4)
    end
  end

  context 'an attribute with a custom validation message' do
    it 'accepts ensuring the correct range' do
      expect(validating_exclusion(in: 2..4, message: 'not good')).
        to validate_exclusion_of(:attr).in_range(2..4).with_message(/not good/)
    end
  end

  context 'an attribute with custom range validations' do
    it 'accepts ensuring the correct range and messages' do
      model = custom_validation do
        if attr >= 2 && attr <= 5
          errors.add(:attr, 'should be out of this range')
        end
      end

      expect(model).to validate_exclusion_of(:attr).in_range(2..5).
        with_message(/should be out of this range/)

      model = custom_validation do
        if attr >= 2 && attr <= 4
          errors.add(:attr, 'should be out of this range')
        end
      end

      expect(model).to validate_exclusion_of(:attr).in_range(2...5).
        with_message(/should be out of this range/)
    end
  end

  context 'an attribute which must be excluded from an array' do
    it 'accepts with correct array' do
      expect(validating_exclusion(in: %w(one two))).
        to validate_exclusion_of(:attr).in_array(%w(one two))
    end

    it 'rejects when only part of array matches' do
      expect(validating_exclusion(in: %w(one two))).
        not_to validate_exclusion_of(:attr).in_array(%w(one wrong_value))
    end

    it 'rejects when array does not match at all' do
      expect(validating_exclusion(in: %w(one two))).
        not_to validate_exclusion_of(:attr).in_array(%w(cat dog))
    end

    it 'has correct description' do
      expect(validate_exclusion_of(:attr).in_array([true, 'dog']).description).
        to eq 'ensure exclusion of attr in [true, "dog"]'
    end

    def validating_exclusion(options)
      define_model(:example, attr: :string) do
        validates_exclusion_of :attr, options
      end.new
    end
  end

  def validating_exclusion(options)
    define_model(:example, attr: :integer) do
      validates_exclusion_of :attr, options
    end.new
  end
end
