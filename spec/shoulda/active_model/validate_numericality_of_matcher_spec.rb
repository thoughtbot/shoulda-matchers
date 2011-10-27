require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateNumericalityOfMatcher do

  context "a numeric attribute" do
    before do
      define_model :example, :attr => :string do
        validates_numericality_of :attr
      end
      @model = Example.new
    end

    it "should only allow numeric values for that attribute" do
      @model.should validate_numericality_of(:attr)
    end

    it "should not override the default message with a blank" do
      @model.should validate_numericality_of(:attr).with_message(nil)
    end
  end

  context "a numeric attribute which must be integer" do
    before do
      define_model :example, :attr => :string do
          validates_numericality_of :attr, { :only_integer => true }
      end
      @model = Example.new
    end

    it "should only allow integer values for that attribute" do
      @model.should validate_numericality_of(:attr).only_integer
    end
  end

  context "a numeric attribute with a custom validation message" do
    before do
      define_model :example, :attr => :string do
        validates_numericality_of :attr, :message => 'custom'
      end
      @model = Example.new
    end

    it "should only allow numeric values for that attribute with that message" do
      @model.should validate_numericality_of(:attr).with_message(/custom/)
    end

    it "should not allow numeric values for that attribute with another message" do
      @model.should_not validate_numericality_of(:attr)
    end
  end

  context "a non-numeric attribute" do
    before do
      @model = define_model(:example, :attr => :string).new
    end

    it "should not only allow numeric values for that attribute" do
      @model.should_not validate_numericality_of(:attr)
    end
  end

end
