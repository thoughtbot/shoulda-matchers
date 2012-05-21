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

      class ValidatePresenceOfMatcher # :nodoc:
        def initialize(attribute)
          @attribute = attribute
          @submatchers = CompositeMatcher.new
        end

        def with_message(message)
          @submatchers.add_matcher WithMessageMatcher.new(@attribute, nil, message)
        end

        def matches?(subject)
          blank_value = BlankValue.new(subject, @attribute).value
          @submatchers.add_matcher DisallowValueMatcher.new(blank_value).for(@attribute)
          @submatchers.matches?(subject)
        end

        def description
          @submatchers.descriptions
        end

        def failure_message
          @submatchers.failure_message
        end

        def negative_failure_message
          @submatchers.negative_failure_message
        end
      end
    end
  end
end
