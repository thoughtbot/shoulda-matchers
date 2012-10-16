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

      class ValidateNumericalityOfMatcher
        def initialize(attribute)
          @attribute = attribute
          @options = {}
          @submatchers = []

          add_disallow_value_matcher
        end

        def only_integer
          only_integer_matcher = OnlyIntegerMatcher.new(@attribute)
          add_submatcher(only_integer_matcher)

          self
        end

        def with_message(message)
          @expected_message = message
          self
        end

        def matches?(subject)
          @subject = subject
          set_expected_message_on_submatchers
          submatchers_match?
        end

        def description
          "only allow #{allowed_types} values for #{@attribute}"
        end

        def failure_message
          @disallow_value_matcher.failure_message
        end

        private

        def add_disallow_value_matcher
          @disallow_value_matcher = DisallowValueMatcher.new('abcd').for(@attribute)
          add_submatcher(@disallow_value_matcher)
        end

        def add_submatcher(submatcher)
          @submatchers << submatcher
        end

        def set_expected_message_on_submatchers
          message = @expected_message || :not_a_number
          @submatchers.each { |matcher| matcher.with_message(message) }
        end

        def submatchers_match?
          @submatchers.all? { |matcher| matcher.matches?(@subject) }
        end

        def allowed_types
          allowed = ["numeric"] + submatcher_allowed_types
          allowed.join(", ")
        end

        def submatcher_allowed_types
          @submatchers.map(&:allowed_types).reject { |type| type.empty? }
        end
      end
    end
  end
end
