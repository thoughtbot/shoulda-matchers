require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::EnsureLengthOfMatcher do

  context "an attribute with a non-zero minimum length validation" do
    before do
      @model = define_model(:example, :attr => :string) do
        validates_length_of :attr, :minimum => 4
      end.new
    end

    it "should accept ensuring the correct minimum length" do
      @model.should ensure_length_of(:attr).is_at_least(4)
    end

    it "should reject ensuring a lower minimum length with any message" do
      @model.should_not ensure_length_of(:attr).is_at_least(3).with_short_message(/.*/)
    end

    it "should reject ensuring a higher minimum length with any message" do
      @model.should_not ensure_length_of(:attr).is_at_least(5).with_short_message(/.*/)
    end

    it "should not override the default message with a blank" do
      @model.should ensure_length_of(:attr).is_at_least(4).with_short_message(nil)
    end
  end

  context "an attribute with a minimum length validation of 0" do
    before do
      @model = define_model(:example, :attr => :string) do
        validates_length_of :attr, :minimum => 0
      end.new
    end

    it "should accept ensuring the correct minimum length" do
      @model.should ensure_length_of(:attr).is_at_least(0)
    end
  end

  context "an attribute with a maximum length" do
    before do
      @model = define_model(:example, :attr => :string) do
        validates_length_of :attr, :maximum => 4
      end.new
    end

    it "should accept ensuring the correct maximum length" do
      @model.should ensure_length_of(:attr).is_at_most(4)
    end

    it "should reject ensuring a lower maximum length with any message" do
      @model.should_not ensure_length_of(:attr).is_at_most(3).with_long_message(/.*/)
    end

    it "should reject ensuring a higher maximum length with any message" do
      @model.should_not ensure_length_of(:attr).is_at_most(5).with_long_message(/.*/)
    end

    it "should not override the default message with a blank" do
      @model.should ensure_length_of(:attr).is_at_most(4).with_long_message(nil)
    end
  end

  context "an attribute with a required exact length" do
    before do
      @model = define_model(:example, :attr => :string) do
        validates_length_of :attr, :is => 4
      end.new
    end

    it "should accept ensuring the correct length" do
      @model.should ensure_length_of(:attr).is_equal_to(4)
    end

    it "should reject ensuring a lower maximum length with any message" do
      @model.should_not ensure_length_of(:attr).is_equal_to(3).with_message(/.*/)
    end

    it "should reject ensuring a higher maximum length with any message" do
      @model.should_not ensure_length_of(:attr).is_equal_to(5).with_message(/.*/)
    end

    it "should not override the default message with a blank" do
      @model.should ensure_length_of(:attr).is_equal_to(4).with_message(nil)
    end
  end

  context "an attribute with a required exact length and another validation" do
    before do
      @model = define_model(:example, :attr => :string) do
        validates_length_of :attr, :is => 4
        validates_numericality_of :attr
      end.new
    end

    it "should accept ensuring the correct length" do
      @model.should ensure_length_of(:attr).is_equal_to(4)
    end
  end

  context "an attribute with a custom minimum length validation" do
    before do
      @model = define_model(:example, :attr => :string) do
        validates_length_of :attr, :minimum => 4, :too_short => 'short'
      end.new
    end

    it "should accept ensuring the correct minimum length" do
      @model.should ensure_length_of(:attr).is_at_least(4).with_short_message(/short/)
    end

  end

  context "an attribute with a custom maximum length validation" do
    before do
      @model = define_model(:example, :attr => :string) do
        validates_length_of :attr, :maximum => 4, :too_long => 'long'
      end.new
    end

    it "should accept ensuring the correct minimum length" do
      @model.should ensure_length_of(:attr).is_at_most(4).with_long_message(/long/)
    end

  end

  context "an attribute without a length validation" do
    before do
      @model = define_model(:example, :attr => :string).new
    end

    it "should reject ensuring a minimum length" do
      @model.should_not ensure_length_of(:attr).is_at_least(1)
    end
  end

end
