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
      #   it { should validate_presence_of(:name).with_message(/is not optional/) }
      #
      def validate_presence_of(attr)
        ValidatePresenceOfMatcher.new(attr)
      end

      class ValidatePresenceOfMatcher # :nodoc:
        def initialize(attribute)
          @attribute = attribute
          @composite_matcher = CompositeMatcher.new
        end

        def with_message(message)
          @composite_matcher.add_matcher WithMessageMatcher.new(@attribute, nil, message)
        end

        def matches?(subject)
          blank_value = BlankValue.new(subject, @attribute).value
          @composite_matcher.add_matcher DisallowValueMatcher.new(blank_value).for(@attribute)
          @composite_matcher.matches?(subject)
        end

        def description
          @composite_matcher.description
        end

        def failure_message
          @composite_matcher.failure_message
        end

        def negative_failure_message
          @composite_matcher.negative_failure_message
        end
      end
    end
  end
end
