require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::EnsureExclusionOfMatcher do
  context 'an attribute which must be excluded from a range' do
    it 'accepts ensuring the correct range' do
      validating_exclusion(:in => 2..5).
        should ensure_exclusion_of(:attr).in_range(2..5)
    end

    it 'rejects ensuring excluded value' do
      validating_exclusion(:in => 2..5).
        should_not ensure_exclusion_of(:attr).in_range(2..6)
    end

    it 'does not override the default message with a blank' do
      validating_exclusion(:in => 2..5).
        should ensure_exclusion_of(:attr).in_range(2..5).with_message(nil)
    end
  end

  context 'an attribute which must be excluded from a range with excluded end' do
    it 'accepts ensuring the correct range' do
      validating_exclusion(:in => 2...5).
        should ensure_exclusion_of(:attr).in_range(2...5)
    end

    it 'rejects ensuring excluded value' do
      validating_exclusion(:in => 2...5).
        should_not ensure_exclusion_of(:attr).in_range(2...4)
    end
  end

  context 'an attribute with a custom validation message' do
    it 'accepts ensuring the correct range' do
      validating_exclusion(:in => 2..4, :message => 'not good').
        should ensure_exclusion_of(:attr).in_range(2..4).with_message(/not good/)
    end
  end

  context 'an attribute with custom range validations' do
    it 'accepts ensuring the correct range and messages' do
      model = custom_validation do
        if attr >= 2 && attr <= 5
          errors.add(:attr, 'should be out of this range')
        end
      end

      model.should ensure_exclusion_of(:attr).in_range(2..5).
        with_message(/should be out of this range/)

      model = custom_validation do
        if attr >= 2 && attr <= 4
          errors.add(:attr, 'should be out of this range')
        end
      end

      model.should ensure_exclusion_of(:attr).in_range(2...5).
        with_message(/should be out of this range/)
    end
  end

  context 'an attribute which must be excluded from an array' do
    it 'accepts with correct array' do
      validating_exclusion(:in => %w(one two)).
        should ensure_exclusion_of(:attr).in_array(%w(one two))
    end

    it 'rejects when only part of array matches' do
      validating_exclusion(:in => %w(one two)).
        should_not ensure_exclusion_of(:attr).in_array(%w(one wrong_value))
    end

    it 'rejects when array does not match at all' do
      validating_exclusion(:in => %w(one two)).
        should_not ensure_exclusion_of(:attr).in_array(%w(cat dog))
    end

    it 'has correct description' do
      ensure_exclusion_of(:attr).in_array([true, 'dog']).description.
        should == 'ensure exclusion of attr in [true, "dog"]'
    end

    def validating_exclusion(options)
      define_model(:example, :attr => :string) do
        validates_exclusion_of :attr, options
      end.new
    end
  end

  def validating_exclusion(options)
    define_model(:example, :attr => :integer) do
      validates_exclusion_of :attr, options
    end.new
  end
end
