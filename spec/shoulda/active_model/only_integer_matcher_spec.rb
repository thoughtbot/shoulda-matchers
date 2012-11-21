require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::OnlyIntegerMatcher do
  context "given an attribute that only allows integer values" do
    before do
      define_model :example, :attr => :string do
        validates_numericality_of :attr, { :only_integer => true }
      end
      @model = Example.new
    end

    it "matches" do
      matcher = new_matcher(:attr)
      matcher.matches?(@model).should be_true
    end

    it "allows integer types" do
      matcher = new_matcher(:attr)
      matcher.allowed_types.should == "integer"
    end

    it "returns itself when given a message" do
      matcher = new_matcher(:attr)
      matcher.with_message("some message").should == matcher
    end
  end

  context "given an attribute that only allows integer values with a custom validation message" do
    before do
      define_model :example, :attr => :string do
        validates_numericality_of :attr, { :only_integer => true, :message => 'custom' }
      end
      @model = Example.new
    end

    it "should only allow integer values for that attribute with that message" do
      matcher = new_matcher(:attr)
      matcher.with_message(/custom/)
      matcher.matches?(@model).should be_true
    end

    it "should not allow integer values for that attribute with another message" do
      matcher = new_matcher(:attr)
      matcher.with_message(/wrong/)
      matcher.matches?(@model).should be_false
    end
  end

  context "given an attribute that allows values other than integers" do
    before do
      @model = define_model(:example, :attr => :string).new
    end

    it "does not match" do
      matcher = new_matcher(:attr)
      matcher.matches?(@model).should be_false
    end

    it "should fail with the ActiveRecord :not_an_integer message" do
      matcher = new_matcher(:attr)
      matcher.matches?(@model)
      matcher.failure_message.should include 'Expected errors to include "must be an integer"'
    end
  end

  def new_matcher(attribute)
    matcher = Shoulda::Matchers::ActiveModel::OnlyIntegerMatcher.new(attribute)
  end
end
