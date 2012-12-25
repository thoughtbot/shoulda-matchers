require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::DisallowValueMatcher do
  it "does not allow any types" do
    matcher = Shoulda::Matchers::ActiveModel::DisallowValueMatcher.new("abcde")
    matcher.allowed_types.should == ""
  end

  context "an attribute with a format validation" do
    before do
      define_model :example, :attr => :string do
        validates_format_of :attr, :with => /abc/
      end
      @model = Example.new
    end

    it "does not match if the value is allowed" do
      matcher = new_matcher("abcde")
      matcher.for(:attr)
      matcher.matches?(@model).should be_false
    end

    it "matches if the value is not allowed" do
      matcher = new_matcher("xyz")
      matcher.for(:attr)
      matcher.matches?(@model).should be_true
    end
  end

  context "an attribute with a format validation and a custom message" do
    before do
      define_model :example, :attr => :string do
        validates_format_of :attr, :with => /abc/, :message => 'good message'
      end
      @model = Example.new
    end

    it "does not match if the value and message are both correct" do
      matcher = new_matcher("abcde")
      matcher.for(:attr).with_message('good message')
      matcher.matches?(@model).should be_false
    end

    it "delegates its failure message to its allow matcher's negative failure message" do
      allow_matcher = stub_everything(:negative_failure_message => "allow matcher failure")
      Shoulda::Matchers::ActiveModel::AllowValueMatcher.stubs(:new).returns(allow_matcher)

      matcher = new_matcher("abcde")
      matcher.for(:attr).with_message('good message')
      matcher.matches?(@model)

      matcher.failure_message.should == "allow matcher failure"
    end

    it "matches if the message is correct but the value is not" do
      matcher = new_matcher("xyz")
      matcher.for(:attr).with_message('good message')
      matcher.matches?(@model).should be_true
    end
  end

  def new_matcher(value)
    matcher = Shoulda::Matchers::ActiveModel::DisallowValueMatcher.new(value)
  end
end
