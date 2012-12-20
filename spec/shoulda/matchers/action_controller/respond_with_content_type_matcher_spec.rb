require 'spec_helper'

describe Shoulda::Matchers::ActionController::RespondWithContentTypeMatcher do
  context "a controller responding with content type :xml" do
    let(:controller) { build_response { render :xml => { :user => "thoughtbot" }.to_xml } }

    it "should accept responding with content type :xml" do
      controller.should respond_with_content_type(:xml)
    end

    it "should accept responding with content type 'application/xml'" do
      controller.should respond_with_content_type('application/xml')
    end

    it "should accept responding with content type /xml/" do
      controller.should respond_with_content_type(/xml/)
    end

    it "should reject responding with another content type" do
      controller.should_not respond_with_content_type(:json)
    end
  end

  it "should generate the correct test name" do
    respond_with_content_type(:xml).description.
      should == "respond with content type of application/xml"
  end
end
