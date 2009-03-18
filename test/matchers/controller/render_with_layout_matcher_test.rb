require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class RenderWithLayoutMatcherTest < ActionController::TestCase # :nodoc:

  context "a controller that renders with a layout" do
    setup do
      @controller = build_response { render :layout => 'wide' }
    end

    should "accept rendering with any layout" do
      assert_accepts render_with_layout, @controller
    end

    should "accept rendering with that layout" do
      assert_accepts render_with_layout(:wide), @controller
    end

    should "reject rendering with another layout" do
      assert_rejects render_with_layout(:other), @controller
    end
  end

  context "a controller that renders without a layout" do
    setup do
      @controller = build_response { render :layout => false }
    end

    should "reject rendering with a layout" do
      assert_rejects render_with_layout, @controller
    end
  end

end
