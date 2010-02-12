module Shoulda # :nodoc:
  module ActionController # :nodoc:
    module Matchers

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

        def initialize(url_or_description, context, &block)
          if block
            @url_block = block
            @location = @url_or_description
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

        attr_reader :failure_message, :negative_failure_message

        def description
          "redirect to #{@location}"
        end

        private

        def redirects_to_url?
          @url = @context.instance_eval(&@url_block) if @url_block
          begin
            @context.send(:assert_redirected_to, @url)
            @negative_failure_message = "Didn't expect to redirect to #{@url}"
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
