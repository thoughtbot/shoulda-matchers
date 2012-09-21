require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::EnsureExclusionOfMatcher do

  context "an attribute which must be excluded of a range" do
    before do
      @model = define_model(:example, :attr => :integer) do
        validates_exclusion_of :attr, :in => 2..5
      end.new
    end

    it "should accept ensuring the correct range" do
      @model.should ensure_exclusion_of(:attr).in_range(2..5)
    end

    it "should reject ensuring excluded value" do
      @model.should_not ensure_exclusion_of(:attr).in_range(2..6)
    end

    it "should not override the default message with a blank" do
      @model.should ensure_exclusion_of(:attr).in_range(2..5).with_message(nil)
    end
  end

  context "an attribute with a custom ranged value validation" do
    before do
      @model = define_model(:example, :attr => :string) do
        validates_exclusion_of :attr, :in => 2..4, :message => 'not good'

      end.new
    end

    it "should accept ensuring the correct range" do
      @model.should ensure_exclusion_of(:attr).in_range(2..4).with_message(/not good/)
    end
  end

  context "an attribute with custom range validations" do
    before do
      define_model :example, :attr => :integer do
        validate :custom_validation
        def custom_validation
          if attr >= 2 && attr <= 5
            errors.add(:attr, 'shoud be out of this range')
          end
        end
      end
      @model = Example.new
    end

    it "should accept ensuring the correct range and messages" do
      @model.should ensure_exclusion_of(:attr).in_range(2..5).with_message(/shoud be out of this range/)
    end
  end

  context "an attribute which must be excluded in an array" do
    before do
      @model = define_model(:example, :attr => :string) do
        validates_exclusion_of :attr, :in => %w(one two)
      end.new
    end

    it "accepts with correct array" do
      @model.should ensure_exclusion_of(:attr).in_array(%w(one two))
    end

    it "rejects when only part of array matches" do
      @model.should_not ensure_exclusion_of(:attr).in_array(%w(one wrong_value))
    end

    it "rejects when array doesn't match at all" do
      @model.should_not ensure_exclusion_of(:attr).in_array(%w(cat dog))
    end

    it "has correct description" do
      ensure_exclusion_of(:attr).in_array([true, 'dog']).description.should == 'ensure exclusion of attr in [true, "dog"]'
    end
  end
end
