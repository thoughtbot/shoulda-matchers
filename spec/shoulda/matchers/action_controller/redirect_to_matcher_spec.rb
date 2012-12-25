require 'spec_helper'

describe Shoulda::Matchers::ActionController::RedirectToMatcher do
  context "a controller that redirects" do
    let(:controller) do
      build_response { redirect_to '/some/url' }
    end

    it "accepts redirecting to that url" do
      controller.should redirect_to('/some/url')
    end

    it "rejects redirecting to a different url" do
      controller.should_not redirect_to('/some/other/url')
    end

    it "accepts redirecting to that url in a block" do
      controller.should redirect_to('somewhere') { '/some/url' }
    end

    it "rejects redirecting to a different url in a block" do
      controller.should_not redirect_to('somewhere else') { '/some/other/url' }
    end
  end

  context "a controller that doesn't redirect" do
    let(:controller) do
      build_response { render :text => 'hello' }
    end

    it "rejects redirecting to a url" do
      controller.should_not redirect_to('/some/url')
    end
  end

  it "provides the correct description when provided a block" do
    matcher = redirect_to('somewhere else') { '/some/other/url' }
    matcher.description.should == 'redirect to somewhere else'
  end
end
