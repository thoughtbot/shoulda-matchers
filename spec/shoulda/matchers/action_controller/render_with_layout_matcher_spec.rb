require 'spec_helper'

describe Shoulda::Matchers::ActionController::RenderWithLayoutMatcher do
  include ActionController::TemplateAssertions

  context 'a controller that renders with a layout' do
    it 'accepts rendering with any layout' do
      controller_with_wide_layout.should render_with_layout
    end

    it 'accepts rendering with that layout' do
      controller_with_wide_layout.should render_with_layout(:wide)
    end

    it 'rejects rendering with another layout' do
      controller_with_wide_layout.should_not render_with_layout(:other)
    end

    def controller_with_wide_layout
      create_view('layouts/wide.html.erb', 'some content, <%= yield %>')
      build_response { render :layout => 'wide' }
    end
  end

  context 'a controller that renders without a layout' do

    it 'rejects rendering with a layout' do
      controller_without_layout = build_response { render :layout => false }

      controller_without_layout.should_not render_with_layout
    end
  end

  context 'a controller that renders a partial' do
    it 'rejects rendering with a layout' do
      controller_with_partial = build_response { render :partial => 'partial' }

      controller_with_partial.should_not render_with_layout
    end
  end

  context 'given a context with layouts' do
    it 'accepts that layout in that context' do
      set_in_context_layout('happy')

      controller_without_layout.should render_with_layout('happy').in_context(self)
    end

    def set_in_context_layout(layout)
      @layouts = Hash.new(0)
      @layouts[layout] = 1
    end

    def controller_without_layout
      build_response { render :layout => false }
    end
  end
end
