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
      def render_with_layout(layout = nil)
        RenderWithLayout.new(layout)
      end

      class RenderWithLayout # :nodoc:

        def initialize(layout)
          @layout = layout.to_s unless layout.nil?
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
          if @layout.nil?
            description << "a layout"
          else
            description << "the #{@layout.inspect} layout"
          end
          description
        end

        private

        def rendered_with_layout?
          !layout.blank?
        end

        def rendered_with_expected_layout?
          return true if @layout.nil?
          layout == @layout
        end

        def layout
          layout = @controller.response.layout
          if layout.nil?
            nil
          else
            layout.split('/').last
          end
        end

        def expectation
          "to #{description}"
        end

        def result
          if rendered_with_layout?
            "rendered with the #{layout.inspect} layout"
          else
            "rendered without a layout"
          end
        end

      end

    end
  end
end
