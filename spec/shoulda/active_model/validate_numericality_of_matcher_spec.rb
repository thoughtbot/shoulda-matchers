require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateNumericalityOfMatcher do
  it "should state in its description that it allows only numeric values" do
    matcher = Shoulda::Matchers::ActiveModel::ValidateNumericalityOfMatcher.new(:attr)
    matcher.description.should == "only allow numeric values for attr"
  end

  context "given a numeric attribute" do
    before do
      define_model :example, :attr => :string do
        validates_numericality_of :attr
      end
      @model = Example.new
    end

    it "should only allow numeric values for that attribute" do
      matcher = new_matcher(:attr)
      matcher.matches?(@model).should be_true
    end

    it "should not override the default message with a blank" do
      matcher = new_matcher(:attr)
      matcher.with_message(nil)
      matcher.matches?(@model).should be_true
    end

    context "when asked to enforce integer values for that attribute" do
      it "should not match" do
        matcher = new_matcher(:attr)
        matcher.only_integer
        matcher.matches?(@model).should be_false
      end

      it "should fail with the ActiveRecord :not_an_integer message" do
        matcher = new_matcher(:attr)
        matcher.only_integer
        matcher.matches?(@model)
        matcher.failure_message.should include 'Expected errors to include "must be an integer"'
      end
    end
  end

  context "given a numeric attribute which must be integer" do
    before do
      define_model :example, :attr => :string do
        validates_numericality_of :attr, { :only_integer => true }
      end
      @model = Example.new
    end

    it "allows integer values for that attribute" do
      matcher = new_matcher(:attr)
      matcher.only_integer
      matcher.matches?(@model).should be_true
    end

    it "does not allow non-integer values for that attribute" do
      matcher = new_matcher(:attr)
      matcher.only_integer
      matcher.matches?(@model).should be_true
    end

    it "should state in its description that it allows only integer values" do
      matcher = new_matcher(:attr)
      matcher.only_integer
      matcher.description.should == "only allow numeric, integer values for attr"
    end
  end

  context "given a numeric attribute with a custom validation message" do
    before do
      define_model :example, :attr => :string do
        validates_numericality_of :attr, :message => 'custom'
      end
      @model = Example.new
    end

    it "should only allow numeric values for that attribute with that message" do
      matcher = new_matcher(:attr)
      matcher.with_message(/custom/)
      matcher.matches?(@model).should be_true
    end

    it "should not allow numeric values for that attribute with another message" do
      matcher = new_matcher(:attr)
      matcher.with_message(/wrong/)
      matcher.matches?(@model).should be_false
    end
  end

  context "given a non-numeric attribute" do
    before do
      @model = define_model(:example, :attr => :string).new
    end

    it "should not only allow numeric values for that attribute" do
      matcher = new_matcher(:attr)
      matcher.matches?(@model).should be_false
    end

    it "should fail with the ActiveRecord :not_a_number message" do
      matcher = new_matcher(:attr)
      matcher.matches?(@model)
      matcher.failure_message.should include 'Expected errors to include "is not a number"'
    end
  end

  def new_matcher(attr)
    Shoulda::Matchers::ActiveModel::ValidateNumericalityOfMatcher.new(attr)
  end
end
