require 'test_helper'

class RedirectToMatcherTest < ActionController::TestCase # :nodoc:

  context "a controller that redirects" do
    setup do
      @controller = build_response { redirect_to '/some/url' }
    end

    should "accept redirecting to that url" do
      assert_accepts redirect_to('/some/url'), @controller
    end

    should "reject redirecting to a different url" do
      assert_rejects redirect_to('/some/other/url'), @controller
    end

    should "accept redirecting to that url in a block" do
      assert_accepts redirect_to('somewhere') { '/some/url' }, @controller
    end

    should "reject redirecting to a different url in a block" do
      assert_rejects redirect_to('somewhere else') { '/some/other/url' }, @controller
    end
  end

  context "a  controller that doesn't redirect" do
    setup do
      @controller = build_response { render :text => 'hello' }
    end

    should "reject redirecting to a url" do
      assert_rejects redirect_to('/some/url'), @controller
    end
  end

end
