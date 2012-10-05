module Shoulda # :nodoc:
  module Matchers
    module ActionController # :nodoc:

      # DEPRECATED - This matcher will be removed in ShouldaMatchers 2.0, please remove all references to it.
      def respond_with_content_type(content_type)
        RespondWithContentTypeMatcher.new(content_type)
      end

      class RespondWithContentTypeMatcher # :nodoc:
        def initialize(content_type)
          ActiveSupport::Deprecation.warn("'respond_with_content_type' will be removed in ShouldaMatchers 2.0.")
          @content_type = look_up_content_type(content_type)
        end

        def description
          "respond with content type of #{@content_type}"
        end

        def matches?(controller)
          @controller = controller
          content_type_matches_regexp? || content_type_matches_string?
        end

        def failure_message
          "Expected #{expectation}"
        end

        def negative_failure_message
          "Did not expect #{expectation}"
        end

        protected

        def content_type_matches_regexp?
          if @content_type.is_a?(Regexp)
            response_content_type =~ @content_type
          end
        end

        def content_type_matches_string?
          response_content_type == @content_type
        end

        def response_content_type
          @controller.response.content_type.to_s
        end

        def look_up_by_extension(extension)
          Mime::Type.lookup_by_extension(extension.to_s).to_s
        end

        def look_up_content_type(content_type)
          if content_type.is_a?(Symbol)
            look_up_by_extension(content_type)
          else
            content_type
          end
        end

        def expectation
          "content type to be #{@content_type}, but was #{response_content_type}"
        end
      end
    end
  end
end
