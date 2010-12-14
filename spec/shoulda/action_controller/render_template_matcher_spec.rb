require 'spec_helper'

describe Shoulda::ActionController::RenderTemplateMatcher do
  include ActionController::TemplateAssertions

  context "a controller that renders a template" do
    before do
      @controller = build_response(:action => 'show') { render }
    end

    it "should accept rendering that template" do
      @controller.should render_template(:show)
    end

    it "should reject rendering a different template" do
      @controller.should_not render_template(:index)
    end

    it "should accept rendering that template in the given context" do
      @controller.should render_template(:show).in_context(self)
    end

    it "should reject rendering a different template in the given context" do
      @controller.should_not render_template(:index).in_context(self)
    end
  end

  context "a  controller that doesn't render a template" do
    before do
      @controller = build_response { render :nothing => true }
    end

    it "should reject rendering a template" do
      @controller.should_not render_template(:show)
    end
  end

end
