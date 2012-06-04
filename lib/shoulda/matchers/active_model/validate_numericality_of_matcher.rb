module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      # Ensure that the attribute is numeric.
      #
      # Options:
      # * <tt>with_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt>. Regexp or string.  Defaults to the
      #   translation for <tt>:not_a_number</tt>.
      # * <tt>only_integer</tt> - allows only integer values
      #
      # Examples:
      #   it { should validate_numericality_of(:price) }
      #   it { should validate_numericality_of(:age).only_integer }
      #
      def validate_numericality_of(attr)
        ValidateNumericalityOfMatcher.new(attr)
      end

      class ValidateNumericalityOfMatcher < ValidationMatcher # :nodoc:
        def initialize(attribute)
          super(attribute)
          @options = {}
        end

        def only_integer
          @options[:only_integer] = true
          self
        end

        def with_message(message)
          if message
            @expected_message = message
          end
          self
        end

        def matches?(subject)
          super(subject)
          disallows_non_integers? && disallows_text?
        end

        def description
          "only allow #{allowed_type} values for #{@attribute}"
        end

        private

        def allowed_type
          if @options[:only_integer]
            "integer"
          else
            "numeric"
          end
        end

        def disallows_non_integers?
          if @options[:only_integer]
            message = @expected_message || :not_an_integer
            disallows_value_of(0.1, message)
          else
            true
          end
        end

        def disallows_text?
          message = @expected_message || :not_a_number
          disallows_value_of('abcd', message)
        end
      end
    end
  end
end
