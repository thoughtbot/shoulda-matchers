require 'test_helper'

class RenderTemplateMatcherTest < ActionController::TestCase # :nodoc:

  context "a controller that renders a template" do
    setup do
      @controller = build_response(:action => 'show') { render }
    end

    should "accept rendering that template" do
      assert_accepts render_template(:show), @controller
    end

    should "reject rendering a different template" do
      assert_rejects render_template(:index), @controller
    end

    should "accept rendering that template in the given context" do
      assert_accepts self.class.render_template(:show).in_context(self), @controller
    end

    should "reject rendering a different template in the given context" do
      assert_rejects self.class.render_template(:index).in_context(self), @controller
    end
  end

  context "a  controller that doesn't render a template" do
    setup do
      @controller = build_response { render :nothing => true }
    end

    should "reject rendering a template" do
      assert_rejects render_template(:show), @controller
    end
  end

end
