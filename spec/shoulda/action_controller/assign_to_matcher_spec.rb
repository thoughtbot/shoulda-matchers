require 'spec_helper'

describe Shoulda::ActionController::AssignToMatcher do

  context "a controller that assigns to an instance variable" do
    before do
      @controller = build_response { @var = 'value' }
    end

    it "should accept assigning to that variable" do
      @controller.should assign_to(:var)
    end

    it "should accept assigning to that variable with the correct class" do
      @controller.should assign_to(:var).with_kind_of(String)
    end

    it "should reject assigning to that variable with another class" do
      @controller.should_not assign_to(:var).with_kind_of(Fixnum)
    end

    it "should accept assigning the correct value to that variable" do
      @controller.should assign_to(:var).with('value')
    end

    it "should reject assigning another value to that variable" do
      @controller.should_not assign_to(:var).with('other')
    end

    it "should reject assigning to another variable" do
      @controller.should_not assign_to(:other)
    end

    it "should accept assigning to the same value in the test context" do
      @expected = 'value'
      @controller.should assign_to(:var).in_context(self).with { @expected }
    end

    it "should reject assigning to the another value in the test context" do
      @expected = 'other'
      @controller.should_not assign_to(:var).in_context(self).with { @expected }
    end
  end

  context "a controller that assigns a nil value to an instance variable" do
    before do
      @controller = build_response { @var = nil }
    end

    it "should accept assigning to that variable" do
      @controller.should assign_to(:var)
    end
  end

end
