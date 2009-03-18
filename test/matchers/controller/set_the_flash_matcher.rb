require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class SetTheFlashMatcherTest < ActionController::TestCase # :nodoc:

  context "a controller that sets a flash message" do
    setup do
      @controller = build_response { flash[:notice] = 'value' }
    end

    should "accept setting any flash message" do
      assert_accepts set_the_flash, @controller
    end

    should "accept setting the exact flash message" do
      assert_accepts set_the_flash.to('value'), @controller
    end

    should "accept setting a matched flash message" do
      assert_accepts set_the_flash.to(/value/), @controller
    end

    should "reject setting a different flash message" do
      assert_rejects set_the_flash.to('other'), @controller
    end

    should "reject setting a different pattern" do
      assert_rejects set_the_flash.to(/other/), @controller
    end
  end

  context "a controller that doesn't set a flash message" do
    setup do
      @controller = build_response
    end

    should "reject setting any flash message" do
      assert_rejects set_the_flash, @controller
    end
  end

end
