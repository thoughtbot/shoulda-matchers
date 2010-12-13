module Shoulda # :nodoc:
  module ActionController # :nodoc:
    module Matchers

      # Ensures a controller rendered the given template.
      #
      # Example:
      #
      #   it { should render_template(:show)  }
      def render_template(template)
        RenderTemplateMatcher.new(template, self)
      end

      class RenderTemplateMatcher # :nodoc:

        def initialize(template, context)
          @template = template.to_s
          @context  = context
        end

        def matches?(controller)
          @controller = controller
          renders_template?
        end

        attr_reader :failure_message, :negative_failure_message

        def description
          "render template #{@template}"
        end

        def in_context(context)
          @context = context
          self
        end

        private

        def renders_template?
          begin
            @context.send(:assert_template, @template)
            @negative_failure_message = "Didn't expect to render #{@template}"
            true
          rescue Test::Unit::AssertionFailedError => error
            @failure_message = error.message
            false
          end
        end

      end

    end
  end
end
