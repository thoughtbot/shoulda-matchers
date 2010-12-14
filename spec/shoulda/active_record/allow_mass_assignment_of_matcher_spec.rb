require 'spec_helper'

describe Shoulda::ActiveRecord::Matchers::AllowMassAssignmentOfMatcher do

  context "an attribute that is blacklisted from mass-assignment" do
    before do
      define_model :example, :attr => :string do
        attr_protected :attr
      end
      @model = Example.new
    end

    it "should reject being mass-assignable" do
      @model.should_not allow_mass_assignment_of(:attr)
    end
  end

  context "an attribute that is not whitelisted for mass-assignment" do
    before do
      define_model :example, :attr => :string, :other => :string do
        attr_accessible :other
      end
      @model = Example.new
    end

    it "should reject being mass-assignable" do
      @model.should_not allow_mass_assignment_of(:attr)
    end
  end

  context "an attribute that is whitelisted for mass-assignment" do
    before do
      define_model :example, :attr => :string do
        attr_accessible :attr
      end
      @model = Example.new
    end

    it "should accept being mass-assignable" do
      @model.should allow_mass_assignment_of(:attr)
    end
  end

  context "an attribute not included in the mass-assignment blacklist" do
    before do
      define_model :example, :attr => :string, :other => :string do
        attr_protected :other
      end
      @model = Example.new
    end

    it "should accept being mass-assignable" do
      @model.should allow_mass_assignment_of(:attr)
    end
  end

  context "an attribute on a class with no protected attributes" do
    before do
      define_model :example, :attr => :string
      @model = Example.new
    end

    it "should accept being mass-assignable" do
      @model.should allow_mass_assignment_of(:attr)
    end

    it "should assign a negative failure message" do
      matcher = allow_mass_assignment_of(:attr)
      matcher.matches?(@model).should == true
      matcher.negative_failure_message.should_not be_nil
    end
  end

end
