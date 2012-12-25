require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateConfirmationOfMatcher do

  context "an attribute which needs confirmation" do
    before do
      define_model(:example, :attr => :string) do
        validates_confirmation_of :attr
      end
      @model = Example.new
    end

    it "should require confirmation of that attribute" do
      @model.should validate_confirmation_of(:attr)
    end

    it "should not override the default message with a blank" do
      @model.should validate_confirmation_of(:attr).with_message(nil)
    end
  end

  context "an attribute which must be confirmed with a custom message" do
    before do
      define_model :example, :attr => :string do
        validates_confirmation_of :attr, :message => 'custom'
      end
      @model = Example.new
    end

    it "should require confirmation of that attribute with that message" do
      @model.should validate_confirmation_of(:attr).with_message(/custom/)
    end

    it "should not require confirmation of that attribute with another message" do
      @model.should_not validate_confirmation_of(:attr)
    end
  end

  context "an attribute which doesn't need confirmation" do
    before do
      @model = define_model(:example, :attr => :string).new
    end

    it "should not require confirmation of that attribute" do
      @model.should_not validate_confirmation_of(:attr)
    end
  end
end
