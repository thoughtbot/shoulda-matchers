require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::EnsureInclusionOfMatcher do
  context 'with no validations' do
    it 'rejects an array which does not have a validator defined' do
      define_model(:example, :attr => :string).new.
        should_not ensure_inclusion_of(:attr).in_array(%w(Yes No))
    end
  end

  context 'with true/false values' do
    it 'can verify outside values to ensure the negative case' do
      define_model(:example, :attr => :string).new.
        should_not ensure_inclusion_of(:attr).in_array([true, false])
    end
  end

  context 'where we cannot determine a value outside the array' do
    it 'raises a custom exception' do
      model = define_model(:example, :attr => :string).new

      arbitrary_string = described_class::ARBITRARY_OUTSIDE_STRING
      expect { model.should ensure_inclusion_of(:attr).in_array([arbitrary_string]) }.to raise_error Shoulda::Matchers::ActiveModel::CouldNotDetermineValueOutsideOfArray
    end
  end

  context 'an attribute which must be included in a range' do
    it 'accepts ensuring the correct range' do
      validating_inclusion(:in => 2..5).
        should ensure_inclusion_of(:attr).in_range(2..5)
    end

    it 'rejects ensuring a lower minimum value' do
      validating_inclusion(:in => 2..5).
        should_not ensure_inclusion_of(:attr).in_range(1..5)
    end

    it 'rejects ensuring a higher minimum value' do
      validating_inclusion(:in => 2..5).
        should_not ensure_inclusion_of(:attr).in_range(3..5)
    end

    it 'rejects ensuring a lower maximum value' do
      validating_inclusion(:in => 2..5).
        should_not ensure_inclusion_of(:attr).in_range(2..4)
    end

    it 'rejects ensuring a higher maximum value' do
      validating_inclusion(:in => 2..5).
        should_not ensure_inclusion_of(:attr).in_range(2..6)
    end

    it 'does not override the default message with a blank' do
      validating_inclusion(:in => 2..5).
        should ensure_inclusion_of(:attr).in_range(2..5).with_message(nil)
    end
  end

  context 'an attribute which must be included in a range with excluded end' do
    it 'accepts ensuring the correct range' do
      validating_inclusion(:in => 2...5).
        should ensure_inclusion_of(:attr).in_range(2...5)
    end

    it 'rejects ensuring a lower maximum value' do
      validating_inclusion(:in => 2...5).
        should_not ensure_inclusion_of(:attr).in_range(2...4)
    end
  end

  context 'an attribute with a custom ranged value validation' do
    it 'accepts ensuring the correct range' do
      validating_inclusion(:in => 2..4, :message => 'not good').
        should ensure_inclusion_of(:attr).in_range(2..4).with_message(/not good/)
    end
  end

  context 'an attribute with custom range validations' do
    it 'accepts ensuring the correct range and messages' do
      model = custom_validation do
        if attr < 2
          errors.add(:attr, 'too low')
        elsif attr > 5
          errors.add(:attr, 'too high')
        end
      end

      model.should ensure_inclusion_of(:attr).in_range(2..5).
        with_low_message(/low/).with_high_message(/high/)

      model = custom_validation do
        if attr < 2
          errors.add(:attr, 'too low')
        elsif attr > 4
          errors.add(:attr, 'too high')
        end
      end

      model.should ensure_inclusion_of(:attr).in_range(2...5).
        with_low_message(/low/).with_high_message(/high/)
    end
  end

  context 'an attribute which must be included in an array' do
    it 'accepts with correct array' do
      validating_inclusion(:in => %w(one two)).
        should ensure_inclusion_of(:attr).in_array(%w(one two))
    end

    it 'rejects when only part of array matches' do
      validating_inclusion(:in => %w(one two)).
        should_not ensure_inclusion_of(:attr).in_array(%w(one wrong_value))
    end

    it 'rejects when array does not match at all' do
      validating_inclusion(:in => %w(one two)).
        should_not ensure_inclusion_of(:attr).in_array(%w(cat dog))
    end

    it 'has correct description' do
      ensure_inclusion_of(:attr).in_array([true, "dog"]).description.
        should == 'ensure inclusion of attr in [true, "dog"]'
    end

    it 'rejects allow_blank' do
      validating_inclusion(:in => %w(one two)).
        should_not ensure_inclusion_of(:attr).in_array(%w(one two)).allow_blank(true)
    end

    it 'accepts allow_blank(false)' do
      validating_inclusion(:in => %w(one two)).
        should ensure_inclusion_of(:attr).in_array(%w(one two)).allow_blank(false)
    end

    it 'rejects allow_nil' do
      validating_inclusion(:in => %w(one two)).
        should_not ensure_inclusion_of(:attr).in_array(%w(one two)).allow_nil(true)
    end

    it 'accepts allow_nil(false)' do
      validating_inclusion(:in => %w(one two)).
        should ensure_inclusion_of(:attr).in_array(%w(one two)).allow_nil(false)
    end
  end

  context 'with allowed blank and allowed nil' do
    it 'accepts allow_blank' do
      validating_inclusion(:in => %w(one two), :allow_blank => true).
        should ensure_inclusion_of(:attr).in_array(%w(one two)).allow_blank
    end

    it 'rejects allow_blank(false)' do
      validating_inclusion(:in => %w(one two), :allow_blank => true).
        should_not ensure_inclusion_of(:attr).in_array(%w(one two)).allow_blank(false)
    end

    it 'accepts allow_nil' do
      validating_inclusion(:in => %w(one two), :allow_nil => true).
        should ensure_inclusion_of(:attr).in_array(%w(one two)).allow_nil
    end

    it 'rejects allow_nil' do
      validating_inclusion(:in => %w(one two), :allow_nil => true).
        should_not ensure_inclusion_of(:attr).in_array(%w(one two)).allow_nil(false)
    end
  end

  context 'an attribute allowing some blank values but not others' do
    it 'rejects allow_blank' do
      validating_inclusion(:in => ['one', 'two', '']).
        should_not ensure_inclusion_of(:attr).in_array(['one', 'two', '']).allow_blank(true)
    end
  end

  if active_model_3_2?
    context 'a strict attribute which must be included in a range' do
      it 'accepts ensuring the correct range' do
        validating_inclusion(:in => 2..5, :strict => true).
          should ensure_inclusion_of(:attr).in_range(2..5).strict
      end

      it 'rejects ensuring another range' do
        validating_inclusion(:in => 2..5, :strict => true).
          should_not ensure_inclusion_of(:attr).in_range(2..6).strict
      end
    end
  end
end

def validating_inclusion(options)
  define_model(:example, :attr => :string) do
    validates_inclusion_of :attr, options
  end.new
end
