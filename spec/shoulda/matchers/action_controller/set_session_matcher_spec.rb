require 'spec_helper'

describe Shoulda::Matchers::ActionController::SetSessionMatcher do
  context "a controller that sets a session variable" do
    let(:controller) do
      build_response do
        session[:var] = 'value'
        session[:false_var] = false
      end
    end

    it "should accept assigning to that variable" do
      controller.should set_session(:var)
    end

    it "should accept assigning the correct value to that variable" do
      controller.should set_session(:var).to('value')
    end

    it "should reject assigning another value to that variable" do
      controller.should_not set_session(:var).to('other')
    end

    it "should reject assigning to another variable" do
      controller.should_not set_session(:other)
    end

    it "should accept assigning nil to another variable" do
      controller.should set_session(:other).to(nil)
    end

    it "should accept assigning false to that variable" do
      controller.should set_session(:false_var).to(false)
    end

    it "should accept assigning to the same value in the test context" do
      expected = 'value'
      controller.should set_session(:var).in_context(self).to { expected }
    end

    it "should reject assigning to the another value in the test context" do
      expected = 'other'
      controller.should_not set_session(:var).in_context(self).to { expected }
    end
  end
end
