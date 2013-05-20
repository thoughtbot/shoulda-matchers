require 'spec_helper'

describe Shoulda::Matchers::ActionController::RenderTemplateMatcher do
  include ActionController::TemplateAssertions

  context 'a controller that renders a template' do
    it 'accepts rendering that template' do
      controller_with_show.should render_template(:show)
    end

    it 'rejects rendering a different template' do
      controller_with_show.should_not render_template(:index)
    end

    it 'accepts rendering that template in the given context' do
      controller_with_show.should render_template(:show).in_context(self)
    end

    it 'rejects rendering a different template in the given context' do
      controller_with_show.should_not render_template(:index).in_context(self)
    end

    def controller_with_show
      build_response(:action => 'show') { render }
    end
  end

  context 'a controller that renders a partial' do
    it 'accepts rendering that partial' do
      controller_with_customer_partial.
        should render_template(:partial => '_customer')
    end

    it 'rejects rendering a different template' do
      controller_with_customer_partial.
        should_not render_template(:partial => '_client')
    end

    it 'accepts rendering that template in the given context' do
      controller_with_customer_partial.
        should render_template(:partial => '_customer').in_context(self)
    end

    it 'rejects rendering a different template in the given context' do
      controller_with_customer_partial.
        should_not render_template(:partial => '_client').in_context(self)
    end

    def controller_with_customer_partial
      build_response(:partial => '_customer') { render :partial => 'customer' }
    end
  end

  context 'a controller that does not render partials' do
    it 'accepts not rendering a partial' do
      controller = build_response(:action => 'show') { render }

      controller.should render_template(:partial => false)
    end
  end

  context 'a controller that renders a partial several times' do
    it 'accepts rendering that partial twice' do
      controller = build_response(:partial => '_customer') do
        render :partial => 'customer', :collection => [1,2]
      end

      controller.should render_template(:partial => '_customer', :count => 2)
    end
  end

  context 'a controller that does not render a template' do
    it 'rejects rendering a template' do
      build_response { render :nothing => true }.
        should_not render_template(:show)
    end
  end
end
