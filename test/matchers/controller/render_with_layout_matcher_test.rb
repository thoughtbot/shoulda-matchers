require 'test_helper'

class RenderWithLayoutMatcherTest < ActionController::TestCase # :nodoc:

  context "a controller that renders with a layout" do
    setup do
      create_view('layouts/wide.html.erb', 'some content, <%= yield %>')
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

  context "given a context with layouts" do
    setup do
      @layout = 'happy'
      @controller = build_response { render :layout => false }
      @layouts = Hash.new(0)
      @layouts[@layout] = 1
    end

    should "accept that layout in that context" do
      assert_accepts render_with_layout(@layout).in_context(self), @controller
    end
  end

end
