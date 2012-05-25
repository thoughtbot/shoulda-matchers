module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      class WithMessageMatcher
        include Helpers

        def initialize(attribute, bad_value, message)
          @attribute = attribute
          @bad_value = bad_value
          @expected_message = message
        end

        def matches?(subject)
          @subject = subject
          warn_if_message_is_nil? || message_matches?
        end

        def failure_message
          "Expected #{@expected_message}, got #{pretty_error_messages(@subject)}"
        end

        private

        def error_messages
          @subject.errors[@attribute]
        end

        def message_matches?
          set_attribute
          validate
          error_messages.any? do |error_message|
            @expected_message.match(error_message).present?
          end
        end

        def warn_if_message_is_nil?
          if @expected_message.nil?
            ActiveSupport::Deprecation.warn 'Using with_message with a nil parameter is being deprecated.  Please do not use with_message if you do not wish to check for a specific message.', caller
            true
          end
        end

        def set_attribute
          @subject.send("#{@attribute}=", @bad_value)
        end

        def validate
          @subject.valid?
        end
      end
    end
  end
end
