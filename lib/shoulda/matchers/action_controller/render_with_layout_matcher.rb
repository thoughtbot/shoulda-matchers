module Shoulda # :nodoc:
  module Matchers
    module ActionController # :nodoc:

      # Ensures that the controller rendered with the given layout.
      #
      # Example:
      #
      #   it { should render_with_layout }
      #   it { should render_with_layout(:special) }
      #   it { should_not render_with_layout }
      def render_with_layout(expected_layout = nil)
        RenderWithLayoutMatcher.new(expected_layout).in_context(self)
      end

      class RenderWithLayoutMatcher # :nodoc:

        def initialize(expected_layout)
          unless expected_layout.nil?
            @expected_layout = expected_layout.to_s
          end
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
        alias failure_message_for_should failure_message

        def failure_message_when_negated
          "Did not expect #{expectation}, but #{result}"
        end
        alias failure_message_for_should_not failure_message_when_negated

        def description
          description = 'render with '
          if @expected_layout.nil?
            description << 'a layout'
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
          if @expected_layout.nil?
            true
          else
            rendered_layouts.include?(@expected_layout)
          end
        end

        def rendered_layouts
          recorded_layouts.keys.compact.map { |layout| layout.sub(%r{^layouts/}, '') }
        end

        def recorded_layouts
          if @context
            @context.instance_variable_get(Shoulda::Matchers::RailsShim.layouts_ivar)
          else
            {}
          end
        end

        def expectation
          "to #{description}"
        end

        def result
          if rendered_with_layout?
            'rendered with ' + rendered_layouts.map(&:inspect).join(', ')
          else
            'rendered without a layout'
          end
        end
      end
    end
  end
end
