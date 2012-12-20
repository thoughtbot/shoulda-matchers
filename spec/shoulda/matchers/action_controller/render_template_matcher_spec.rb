require 'spec_helper'

describe Shoulda::Matchers::ActionController::RenderTemplateMatcher do
  include ActionController::TemplateAssertions

  context "a controller that renders a template" do
    let(:controller) { build_response(:action => 'show') { render } }

    it "accepts rendering that template" do
      controller.should render_template(:show)
    end

    it "rejects rendering a different template" do
      controller.should_not render_template(:index)
    end

    it "accepts rendering that template in the given context" do
      controller.should render_template(:show).in_context(self)
    end

    it "rejects rendering a different template in the given context" do
      controller.should_not render_template(:index).in_context(self)
    end
  end

  context "a controller that renders a partial" do
    let(:controller) { build_response(:partial => '_customer') { render :partial => 'customer' } }

    it "accepts rendering that partial" do
      controller.should render_template(:partial => '_customer')
    end

    it "rejects rendering a different template" do
      controller.should_not render_template(:partial => '_client')
    end

    it "accepts rendering that template in the given context" do
      controller.should render_template(:partial => '_customer').in_context(self)
    end

    it "rejects rendering a different template in the given context" do
      controller.should_not render_template(:partial => '_client').in_context(self)
    end
  end

  context "a controller that doesn't render partials" do
    let(:controller) { build_response(:action => 'show') { render } }

    it "should not render a partial" do
      controller.should render_template(:partial => false)
    end
  end

  context "a controller that renders a partial several times" do
    let(:controller) { build_response(:partial => '_customer') { render :partial => 'customer', :collection => [1,2] } }

    it "accepts rendering that partial twice" do
      controller.should render_template(:partial => '_customer', :count => 2)
    end
  end

  context "a  controller that doesn't render a template" do
    let(:controller) { build_response { render :nothing => true } }

    it "rejects rendering a template" do
      controller.should_not render_template(:show)
    end
  end
end
