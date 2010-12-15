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

  context "an attribute that can be set after being saved" do
    before do
      define_model :example, :attr => :string
      @model = Example.new
    end

    it "should accept being read-only" do
      @model.should_not have_readonly_attribute(:attr)
    end
  end

end
