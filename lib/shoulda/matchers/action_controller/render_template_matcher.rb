module Shoulda # :nodoc:
  module Matchers
    module ActionController # :nodoc:
      # Ensures a controller rendered the given template.
      #
      # Example:
      #
      #   it { should render_template(:show)  }
      #
      #   assert that the "_customer" partial was rendered
      #   it { should render_template(:partial => '_customer')  }
      #
      #   assert that the "_customer" partial was rendered twice
      #   it { should render_template(:partial => '_customer', :count => 2)  }
      #
      #   assert that no partials were rendered
      #   it { should render_template(:partial => false)  }
      def render_template(options = {}, message = nil)
        RenderTemplateMatcher.new(options, message, self)
      end

      class RenderTemplateMatcher # :nodoc:
        attr_reader :failure_message_for_should, :failure_message_for_should_not

        def initialize(options, message, context)
          @options = options
          @message = message
          @template = options.is_a?(Hash) ? options[:partial] : options
          @context  = context
        end

        def matches?(controller)
          @controller = controller
          renders_template?
        end

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
            @context.send(:assert_template, @options, @message)
            @failure_message_for_should_not = "Didn't expect to render #{@template}"
            true
          rescue Shoulda::Matchers::AssertionError => error
            @failure_message_for_should = error.message
            false
          end
        end
      end
    end
  end
end
