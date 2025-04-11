require 'unit_spec_helper'

describe Shoulda::Matchers::ActionController::RenderWithLayoutMatcher, type: :controller do
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

    it 'produces the correct message for rendering with another layout' do
      expected_message = 'Expected to render with the "other" layout, but rendered with "wide", "wide"'

      expect { expect(controller_with_wide_layout).to render_with_layout(:other) }.
        to fail_with_message(expected_message)
    end

    it 'produces the correct message for the negation' do
      expected_message = 'Did not expect to render with a layout, but rendered with "wide", "wide"'

      expect { expect(controller_with_wide_layout).not_to render_with_layout }.
        to fail_with_message(expected_message)
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

    it 'produces the correct message' do
      controller_without_layout = build_fake_response { render layout: false }
      expected_message = 'Expected to render with a layout, but rendered without a layout'

      expect { expect(controller_without_layout).to render_with_layout }.
        to fail_with_message(expected_message)
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
      context = Object.new
      set_layout_in_context(context, 'happy')

      expect(controller_without_layout).
        to render_with_layout('happy').
        in_context(context)
    end

    def set_layout_in_context(context, layout)
      layouts = Hash.new(0)
      layouts[layout] = 1
      context.instance_variable_set('@_layouts', layouts)
    end

    def controller_without_layout
      build_fake_response { render layout: false }
    end
  end
end
