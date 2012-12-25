require 'spec_helper'

describe Shoulda::Matchers::ActionController::FilterParamMatcher do
  context "given parameter filters" do
    before do
      Rails.application.config.filter_parameters = [:secret]
    end

    it "should accept filtering that parameter" do
      nil.should filter_param(:secret)
    end

    it "should reject filtering another parameter" do
      matcher = filter_param(:other)
      matcher.matches?(nil).should be_false
      matcher.failure_message.should include("Expected other to be filtered")
      matcher.failure_message.should =~ /secret/
    end
  end
end
