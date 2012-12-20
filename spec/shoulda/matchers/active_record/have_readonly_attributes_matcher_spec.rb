require 'spec_helper'

describe Shoulda::Matchers::ActiveRecord::HaveReadonlyAttributeMatcher do
  context "an attribute that cannot be set after being saved" do
    before do
      define_model :example, :attr => :string do
        attr_readonly :attr
      end
      @model = Example.new
    end

    it "should accept being read-only" do
      @model.should have_readonly_attribute(:attr)
    end
  end

  context "an attribute not included in the readonly set" do
    before do
      define_model :example, :attr => :string, :other => :string do
        attr_readonly :other
      end
      @model = Example.new
    end

    it "should not accept being read-only" do
      @model.should_not have_readonly_attribute(:attr)
    end
  end

  context "an attribute on a class with no readonly attributes" do
    before do
      define_model :example, :attr => :string
      @model = Example.new
    end

    it "should not accept being read-only" do
      @model.should_not have_readonly_attribute(:attr)
    end

    it "should assign a failure message" do
      matcher = have_readonly_attribute(:attr)
      matcher.matches?(@model).should == false
      matcher.failure_message.should_not be_nil
    end
  end
end
