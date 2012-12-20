require 'spec_helper'

describe Shoulda::Matchers::ActiveRecord::AcceptNestedAttributesForMatcher do
  before do
    define_model :child, :parent_id => :integer
    define_model :parent do
      has_many :children
    end
  end

  let(:parent) { Parent.new }
  let(:matcher) { accept_nested_attributes_for(:children) }

  it "should accept an existing declaration" do
    Parent.accepts_nested_attributes_for :children
    matcher.matches?(parent).should be_true
  end

  it "should reject a missing declaration" do
    matcher.matches?(parent).should be_false
    matcher.failure_message.should == "Expected Parent to accept nested attributes for children (is not declared)"
  end

  context "allow_destroy" do
    it "should accept a valid truthy value" do
      Parent.accepts_nested_attributes_for :children, :allow_destroy => true
      matcher.allow_destroy(true).matches?(parent).should be_true
    end

    it "should accept a valid falsey value" do
      Parent.accepts_nested_attributes_for :children, :allow_destroy => false
      matcher.allow_destroy(false).matches?(parent).should be_true
    end

    it "should reject an invalid truthy value" do
      Parent.accepts_nested_attributes_for :children, :allow_destroy => true
      matcher.allow_destroy(false).matches?(parent).should be_false
      matcher.failure_message.should =~ /should not allow destroy/
    end

    it "should reject an invalid falsey value" do
      Parent.accepts_nested_attributes_for :children, :allow_destroy => false
      matcher.allow_destroy(true).matches?(parent).should be_false
      matcher.failure_message.should =~ /should allow destroy/
    end
  end

  context "limit" do
    it "should accept a correct value" do
      Parent.accepts_nested_attributes_for :children, :limit => 3
      matcher.limit(3).matches?(parent).should be_true
    end

    it "should reject a false value" do
      Parent.accepts_nested_attributes_for :children, :limit => 3
      matcher.limit(2).matches?(parent).should be_false
      matcher.failure_message.should =~ /limit should be 2, got 3/
    end
  end

  context "update_only" do
    it "should accept a valid truthy value" do
      Parent.accepts_nested_attributes_for :children, :update_only => true
      matcher.update_only(true).matches?(parent).should be_true
    end

    it "should accept a valid falsey value" do
      Parent.accepts_nested_attributes_for :children, :update_only => false
      matcher.update_only(false).matches?(parent).should be_true
    end

    it "should reject an invalid truthy value" do
      Parent.accepts_nested_attributes_for :children, :update_only => true
      matcher.update_only(false).matches?(parent).should be_false
      matcher.failure_message.should =~ /should not be update only/
    end

    it "should reject an invalid falsey value" do
      Parent.accepts_nested_attributes_for :children, :update_only => false
      matcher.update_only(true).matches?(parent).should be_false
      matcher.failure_message.should =~ /should be update only/
    end
  end
end
