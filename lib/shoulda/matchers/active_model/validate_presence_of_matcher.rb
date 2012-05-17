module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      # Ensures that the model is not valid if the given attribute is not
      # present.
      #
      # Options:
      # * <tt>with_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt>. <tt>Regexp</tt> or <tt>String</tt>.
      #   Defaults to the translation for <tt>:blank</tt>.
      #
      # Examples:
      #   it { should validate_presence_of(:name) }
      #   it { should validate_presence_of(:name).
      #                 with_message(/is not optional/) }
      #
      def validate_presence_of(attr)
        ValidatePresenceOfMatcher.new(attr)
      end

      class ValidatePresenceOfMatcher < CompositeMatcher # :nodoc:
        def with_message(message)
          add_matcher WithMessageMatcher.new(@attribute, message)
        end

        def matches?(subject)
          @subject = subject
          blank_value = BlankValue.new(subject, @attribute).value
          disallows_value_of(blank_value) && super
        end

        def description
          my_description = "require #{@attribute} to be set"
          sub_descriptions = sub_matcher_descriptions
          (sub_description + mydescriptions).join(" ")
        end
      end

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
          error_messages.any? do |error_message|
            @expected_message.match(error_message).present?
          end
        end

        def failure_message
          "Expected #{@expected_message} got #{pretty_error_messages(@subject)}"
        end

        private

        def error_messages
          @subject.errors[@attribute]
        end
      end
    end
  end
end
