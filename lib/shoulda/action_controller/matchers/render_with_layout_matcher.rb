module Shoulda # :nodoc:
  module ActionController # :nodoc:
    module Matchers

      # Ensures that the controller rendered with the given layout.
      #
      # Example:
      #
      #   it { should render_with_layout }
      #   it { should render_with_layout(:special) }
      #   it { should_not render_with_layout }
      def render_with_layout(expected_layout = nil)
        RenderWithLayout.new(expected_layout)
      end

      class RenderWithLayout # :nodoc:

        def initialize(expected_layout)
          @expected_layout = expected_layout.to_s unless expected_layout.nil?
        end

        # Used to provide access to layouts recorded by
        # ActionController::TemplateAssertions in Rails 3
        def in_context(context)
          @context = context
          self
        end

        def matches?(controller)
          @controller = controller
          rendered_with_layout? && rendered_with_expected_layout?
        end

        def failure_message
          "Expected #{expectation}, but #{result}"
        end

        def negative_failure_message
          "Did not expect #{expectation}, but #{result}"
        end

        def description
          description = "render with "
          if @expected_layout.nil?
            description << "a layout"
          else
            description << "the #{@expected_layout.inspect} layout"
          end
          description
        end

        private

        def rendered_with_layout?
          !rendered_layouts.empty?
        end

        def rendered_with_expected_layout?
          return true if @expected_layout.nil?
          rendered_layouts.include?(@expected_layout)
        end

        def rendered_layouts
          if recorded_layouts
            recorded_layouts.keys.compact.map { |layout| layout.sub(%r{^layouts/}, '') }
          else
            layout = @controller.response.layout
            if layout.nil?
              []
            else
              [layout.split('/').last]
            end
          end
        end

        def recorded_layouts
          if @context
            @context.instance_variable_get('@layouts')
          end
        end

        def expectation
          "to #{description}"
        end

        def result
          if rendered_with_layout?
            "rendered with " <<
              rendered_layouts.map { |layout| layout.inspect }.join(", ")
          else
            "rendered without a layout"
          end
        end

      end

    end
  end
end
