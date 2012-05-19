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

      class ValidatePresenceOfMatcher
        def initialize(attribute)
          @composite = CompositeMatcher.new(@attribute)
        end

        def with_message(message)
          @composite.add_matcher WithMessageMatcher.new(@attribute, bad_value, message)
        end

        def matches?(subject)
          @subject = subject
          blank_value = BlankValue.new(subject, @attribute).value
          @composite.disallows_value_of(blank_value) &&
            @composite.matches?
        end

        def description
          my_description = "require #{@attribute} to be set"
          (@composite.sub_matcher_descriptions + my_description).join(" ")
        end

        private

        def bad_value
          nil
        end
      end
    end
  end
end
