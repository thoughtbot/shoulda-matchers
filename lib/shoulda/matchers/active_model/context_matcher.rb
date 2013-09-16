module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      class ContextMatcher
        def initialize(context)
          @context = context
        end

        def for(attribute)
          @attribute = attribute
          self
        end

        def matches?(subject)
          @subject = subject
          @subject.valid?(@context)
        end

        def allowed_types
          ''
        end

        def failure_message_for_should
          "Expected validation for '#{@attribute}' to run only on '#{@context}', but didn't."
        end

        def failure_message_for_should_not
          "Expected validation for '#{@attribute}' to not run on '#{@context}', but did."
        end
      end
    end
  end
end
