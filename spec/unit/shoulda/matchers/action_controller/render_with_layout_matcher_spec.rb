require 'spec_helper'

describe Shoulda::Matchers::ActionController::RenderWithLayoutMatcher do
  include ActionController::TemplateAssertions

  context 'a controller that renders with a layout' do
    it 'accepts rendering with any layout' do
      expect(controller_with_wide_layout).to render_with_layout
    end

    it 'accepts rendering with that layout' do
      expect(controller_with_wide_layout).to render_with_layout(:wide)
    end

    it 'rejects rendering with another layout' do
      expect(controller_with_wide_layout).not_to render_with_layout(:other)
    end

    def controller_with_wide_layout
      create_view('layouts/wide.html.erb', 'some content, <%= yield %>')
      build_fake_response { render layout: 'wide' }
    end
  end

  context 'a controller that renders without a layout' do

    it 'rejects rendering with a layout' do
      controller_without_layout = build_fake_response { render layout: false }

      expect(controller_without_layout).not_to render_with_layout
    end
  end

  context 'a controller that renders a partial' do
    it 'rejects rendering with a layout' do
      controller_with_partial = build_fake_response { render partial: 'partial' }

      expect(controller_with_partial).not_to render_with_layout
    end
  end

  context 'given a context with layouts' do
    it 'accepts that layout in that context' do
      set_in_context_layout('happy')

      expect(controller_without_layout).to render_with_layout('happy').in_context(self)
    end

    def set_in_context_layout(layout)
      layouts = Hash.new(0)
      layouts[layout] = 1
      self.instance_variable_set(layouts_ivar, layouts)
    end

    def layouts_ivar
      Shoulda::Matchers::RailsShim.layouts_ivar
    end

    def controller_without_layout
      build_fake_response { render layout: false }
    end
  end
end
