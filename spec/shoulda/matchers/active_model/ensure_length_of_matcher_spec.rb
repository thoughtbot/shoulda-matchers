require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::EnsureLengthOfMatcher do
  context 'an attribute with a non-zero minimum length validation' do
    it 'accepts ensuring the correct minimum length' do
      validating_length(:minimum => 4).
        should ensure_length_of(:attr).is_at_least(4)
    end

    it 'rejects ensuring a lower minimum length with any message' do
      validating_length(:minimum => 4).
        should_not ensure_length_of(:attr).is_at_least(3).with_short_message(/.*/)
    end

    it 'rejects ensuring a higher minimum length with any message' do
      validating_length(:minimum => 4).
        should_not ensure_length_of(:attr).is_at_least(5).with_short_message(/.*/)
    end

    it 'does not override the default message with a blank' do
      validating_length(:minimum => 4).
        should ensure_length_of(:attr).is_at_least(4).with_short_message(nil)
    end
  end

  context 'an attribute with a minimum length validation of 0' do
    it 'accepts ensuring the correct minimum length' do
      validating_length(:minimum => 0).
        should ensure_length_of(:attr).is_at_least(0)
    end
  end

  context 'an attribute with a maximum length' do
    it 'accepts ensuring the correct maximum length' do
      validating_length(:maximum => 4).
        should ensure_length_of(:attr).is_at_most(4)
    end

    it 'rejects ensuring a lower maximum length with any message' do
      validating_length(:maximum => 4).
        should_not ensure_length_of(:attr).is_at_most(3).with_long_message(/.*/)
    end

    it 'rejects ensuring a higher maximum length with any message' do
      validating_length(:maximum => 4).
        should_not ensure_length_of(:attr).is_at_most(5).with_long_message(/.*/)
    end

    it 'does not override the default message with a blank' do
      validating_length(:maximum => 4).
        should ensure_length_of(:attr).is_at_most(4).with_long_message(nil)
    end
  end

  context 'an attribute with a required exact length' do
    it 'accepts ensuring the correct length' do
      validating_length(:is => 4).should ensure_length_of(:attr).is_equal_to(4)
    end

    it 'rejects ensuring a lower maximum length with any message' do
      validating_length(:is => 4).
        should_not ensure_length_of(:attr).is_equal_to(3).with_message(/.*/)
    end

    it 'rejects ensuring a higher maximum length with any message' do
      validating_length(:is => 4).
        should_not ensure_length_of(:attr).is_equal_to(5).with_message(/.*/)
    end

    it 'does not override the default message with a blank' do
      validating_length(:is => 4).
        should ensure_length_of(:attr).is_equal_to(4).with_message(nil)
    end
  end

  context 'an attribute with a required exact length and another validation' do
    it 'accepts ensuring the correct length' do
      model = define_model(:example, :attr => :string) do
        validates_length_of :attr, :is => 4
        validates_numericality_of :attr
      end.new

      model.should ensure_length_of(:attr).is_equal_to(4)
    end
  end

  context 'an attribute with a custom minimum length validation' do
    it 'accepts ensuring the correct minimum length' do
      validating_length(:minimum => 4, :too_short => 'foobar').
        should ensure_length_of(:attr).is_at_least(4).with_short_message(/foo/)
    end
  end

  context 'an attribute with a custom maximum length validation' do
    it 'accepts ensuring the correct minimum length' do
      validating_length(:maximum => 4, :too_long => 'foobar').
        should ensure_length_of(:attr).is_at_most(4).with_long_message(/foo/)
    end
  end

  context 'an attribute without a length validation' do
    it 'rejects ensuring a minimum length' do
      define_model(:example, :attr => :string).new.
        should_not ensure_length_of(:attr).is_at_least(1)
    end
  end

  def validating_length(options = {})
    define_model(:example, :attr => :string) do
      validates_length_of :attr, options
    end.new
  end
end
