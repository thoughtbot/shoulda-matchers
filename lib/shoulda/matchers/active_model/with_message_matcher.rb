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
          subject.send("#{@attribute}=", @bad_value)
          subject.valid?
          message_matches_or_nil?
        end

        def failure_message
          "Expected #{@expected_message} got #{pretty_error_messages(@subject)}"
        end

        private

        def error_messages
          @subject.errors[@attribute]
        end

        def message_matches?
          error_messages.any? do |error_message|
            @expected_message.match(error_message).present?
          end
        end

        def message_matches_or_nil?
         @expected_message.nil? || message_matches?
        end
      end
    end
  end
end
