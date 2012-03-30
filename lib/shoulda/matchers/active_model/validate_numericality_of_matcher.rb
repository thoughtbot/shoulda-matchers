module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
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
          if message
            @expected_message = message
          end
          self
        end

        def matches?(subject)
          super(subject)
          disallows_value_of('abcd', expected_message)
        end

        def description
          "only allow numeric values for #{@attribute}"
        end

        private

        def expected_message
          @expected_message || :not_a_number
        end
      end
    end
  end
end
