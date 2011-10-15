require 'spec_helper'

describe Shoulda::Matchers::ActionController::RenderTemplateMatcher do
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

  context "a controller that renders a partial" do
    before do
      @controller = build_response(:partial => '_customer') { render :partial => 'customer' }
    end

    it "should accept rendering that partial" do
      @controller.should render_template(:partial => '_customer')
    end

    it "should reject rendering a different template" do
      @controller.should_not render_template(:partial => '_client')
    end

    it "should accept rendering that template in the given context" do
      @controller.should render_template(:partial => '_customer').in_context(self)
    end

    it "should reject rendering a different template in the given context" do
      @controller.should_not render_template(:partial => '_client').in_context(self)
    end
  end

  context "a controller that doesn't render partials" do
    before do
      @controller = build_response(:action => 'show') { render }
    end

    it "should not render a partial" do
      @controller.should render_template(:partial => false)
    end
  end

  context "a controller that renders a partial several times" do
    before do
      @controller = build_response(:partial => '_customer') { render :partial => 'customer', :collection => [1,2] }
    end

    it "should accept rendering that partial twice" do
      @controller.should render_template(:partial => '_customer', :count => 2)
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
