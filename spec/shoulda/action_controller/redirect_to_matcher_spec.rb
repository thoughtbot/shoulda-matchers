require 'spec_helper'

describe Shoulda::ActionController::RedirectToMatcher do

  context "a controller that redirects" do
    before do
      @controller = build_response { redirect_to '/some/url' }
    end

    it "should accept redirecting to that url" do
      @controller.should redirect_to('/some/url')
    end

    it "should reject redirecting to a different url" do
      @controller.should_not redirect_to('/some/other/url')
    end

    it "should accept redirecting to that url in a block" do
      @controller.should redirect_to('somewhere') { '/some/url' }
    end

    it "should reject redirecting to a different url in a block" do
      @controller.should_not redirect_to('somewhere else') { '/some/other/url' }
    end
  end

  context "a  controller that doesn't redirect" do
    before do
      @controller = build_response { render :text => 'hello' }
    end

    it "should reject redirecting to a url" do
      @controller.should_not redirect_to('/some/url')
    end
  end

end
