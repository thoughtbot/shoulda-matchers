require 'spec_helper'

describe Shoulda::Matchers::ActionController::RespondWithMatcher do
  context "a controller responding with success" do
    let(:controller) { build_response { render :text => "text", :status => 200 } }

    it "should accept responding with 200" do
      controller.should respond_with(200)
    end

    it "should accept responding with :success" do
      controller.should respond_with(:success)
    end

    it "should reject responding with another status" do
      controller.should_not respond_with(:error)
    end
  end

  context "a controller responding with redirect" do
    let(:controller) { build_response { render :text => "text", :status => 301 } }

    it "should accept responding with 301" do
      controller.should respond_with(301)
    end

    it "should accept responding with :redirect" do
      controller.should respond_with(:redirect)
    end

    it "should reject responding with another status" do
      controller.should_not respond_with(:error)
    end
  end

  context "a controller responding with missing" do
    let(:controller) { build_response { render :text => "text", :status => 404 } }

    it "should accept responding with 404" do
      controller.should respond_with(404)
    end

    it "should accept responding with :missing" do
      controller.should respond_with(:missing)
    end

    it "should reject responding with another status" do
      controller.should_not respond_with(:success)
    end
  end

  context "a controller responding with error" do
    let(:controller) { build_response { render :text => "text", :status => 500 } }

    it "should accept responding with 500" do
      controller.should respond_with(500)
    end

    it "should accept responding with :error" do
      controller.should respond_with(:error)
    end

    it "should reject responding with another status" do
      controller.should_not respond_with(:success)
    end
  end

  context "a controller responding with not implemented" do
    let(:controller) { build_response { render :text => "text", :status => 501 } }

    it "should accept responding with 501" do
      controller.should respond_with(501)
    end

    it "should accept responding with :not_implemented" do
      controller.should respond_with(:not_implemented)
    end

    it "should reject responding with another status" do
      controller.should_not respond_with(:success)
    end
  end
end
