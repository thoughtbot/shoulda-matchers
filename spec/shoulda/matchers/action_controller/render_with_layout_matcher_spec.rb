require 'spec_helper'

describe Shoulda::Matchers::ActionController::RenderWithLayoutMatcher do
  include ActionController::TemplateAssertions

  context "a controller that renders with a layout" do
    let(:controller) { build_response { render :layout => 'wide' } }

    before do
      create_view('layouts/wide.html.erb', 'some content, <%= yield %>')
    end

    it "should accept rendering with any layout" do
      controller.should render_with_layout
    end

    it "should accept rendering with that layout" do
      controller.should render_with_layout(:wide)
    end

    it "should reject rendering with another layout" do
      controller.should_not render_with_layout(:other)
    end
  end

  context "a controller that renders without a layout" do
    let(:controller) { build_response { render :layout => false } }

    it "should reject rendering with a layout" do
      controller.should_not render_with_layout
    end
  end

  context "a controller that renders a partial" do
    let(:controller) { build_response { render :partial => 'partial' } }

    it "should reject rendering with a layout" do
      controller.should_not render_with_layout
    end
  end

  context "given a context with layouts" do
    let(:layout) { 'happy' }
    let(:controller) { build_response { render :layout => false } }

    before do
      @layouts = Hash.new(0)
      @layouts[layout] = 1
    end

    it "should accept that layout in that context" do
      controller.should render_with_layout(layout).in_context(self)
    end
  end
end
