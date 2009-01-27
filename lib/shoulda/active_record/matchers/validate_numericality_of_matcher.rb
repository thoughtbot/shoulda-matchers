module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers

      # Ensure that the attribute is numeric
      #
      # Options:
      # * <tt>with_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt>. Regexp or string.  Defaults to the
      #   translation for <tt>:not_a_number</tt>.
      #
      # Example:
      #   it { should validate_numericality_of(:age) }
      #
      def validate_numericality_of(attr)
        ValidateNumericalityOfMatcher.new(attr)
      end

      class ValidateNumericalityOfMatcher < ValidationMatcher # :nodoc:

        def with_message(message)
          @expected_message = message if message
          self
        end

        def matches?(subject)
          super(subject)
          @expected_message ||= :not_a_number
          disallows_value_of('abcd', @expected_message)
        end

        def description
          "only allow numeric values for #{@attribute}"
        end
      end

    end
  end
end
