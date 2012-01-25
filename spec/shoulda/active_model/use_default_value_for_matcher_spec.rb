require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::UseDefaultValueMatcher do

  context "an attribute with a default value" do
    before do
      define_model :example, :attr => :string do
        before_validation :set_attr
        def set_attr
          self.attr = "abc" if attr.nil?
        end
      end
      @model = Example.new
    end

    it "should use the right default value" do
      @model.should use_default_value("abc").for(:attr)
    end

    it "should use a default value" do
      @model.should use_default_value.for(:attr)
    end

    it "should not use a bad default value" do
      @model.should_not use_default_value("xyz").for(:attr)
    end
  end

  context "an attribute without a default value" do
    before do
      define_model :example, :attr => :string
      @model = Example.new
    end
    it "should not use a default value" do
      @model.should_not use_default_value.for(:attr)
    end

    it "should not use a bad default value" do
      @model.should_not use_default_value("xyz").for(:attr)
    end
  end
end
