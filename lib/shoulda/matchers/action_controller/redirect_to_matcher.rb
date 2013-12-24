module Shoulda # :nodoc:
  module Matchers
    module ActionController # :nodoc:
      # Ensures a controller redirected to the given url.
      #
      # Example:
      #
      #   it { should redirect_to('http://somewhere.com')  }
      #   it { should redirect_to(users_path)  }
      def redirect_to(url_or_description, &block)
        RedirectToMatcher.new(url_or_description, self, &block)
      end

      class RedirectToMatcher # :nodoc:
        attr_reader :failure_message, :failure_message_when_negated

        alias failure_message_for_should failure_message
        alias failure_message_for_should_not failure_message_when_negated

        def initialize(url_or_description, context, &block)
          if block
            @url_block = block
            @location = url_or_description
          else
            @url = url_or_description
            @location = @url
          end
          @context = context
        end

        def in_context(context)
          @context = context
          self
        end

        def matches?(controller)
          @controller = controller
          redirects_to_url?
        end

        def description
          "redirect to #{@location}"
        end

        private

        def redirects_to_url?
          begin
            @context.send(:assert_redirected_to, url)
            @failure_message_when_negated = "Didn't expect to redirect to #{url}"
            true
          rescue Shoulda::Matchers::AssertionError => error
            @failure_message = error.message
            false
          end
        end

        def url
          if @url_block
            @context.instance_eval(&@url_block)
          else
            @url
          end
        end
      end
    end
  end
end
