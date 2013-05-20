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
      # * <tt>odd</tt> - Specifies the value must be an odd number.
      # * <tt>even</tt> - Specifies the value must be an even number.
      #
      # Examples:
      #   it { should validate_numericality_of(:price) }
      #   it { should validate_numericality_of(:age).only_integer }
      #   it { should validate_numericality_of(:frequency).odd }
      #   it { should validate_numericality_of(:frequency).even }
      #
      def validate_numericality_of(attr)
        ValidateNumericalityOfMatcher.new(attr)
      end

      class ValidateNumericalityOfMatcher
        NON_NUMERIC_VALUE = 'abcd'

        def initialize(attribute)
          @attribute = attribute
          @submatchers = []

          add_disallow_value_matcher
        end

        def only_integer
          add_submatcher(OnlyIntegerMatcher.new(@attribute))
          self
        end

        def is_greater_than(value)
          add_submatcher(ComparisonMatcher.new(value, :>).for(@attribute))
          self
        end

        def is_greater_than_or_equal_to(value)
          add_submatcher(ComparisonMatcher.new(value, :>=).for(@attribute))
          self
        end

        def is_equal_to(value)
          add_submatcher(ComparisonMatcher.new(value, :==).for(@attribute))
          self
        end

        def is_less_than(value)
          add_submatcher(ComparisonMatcher.new(value, :<).for(@attribute))
          self
        end

        def is_less_than_or_equal_to(value)
          add_submatcher(ComparisonMatcher.new(value, :<=).for(@attribute))
          self
        end

        def odd
          odd_number_matcher = OddEvenNumberMatcher.new(@attribute, :odd => true)
          add_submatcher(odd_number_matcher)
          self
        end

        def even
          even_number_matcher = OddEvenNumberMatcher.new(@attribute, :even => true)
          add_submatcher(even_number_matcher)
          self
        end

        def with_message(message)
          @submatchers.each { |matcher| matcher.with_message(message) }
          self
        end

        def matches?(subject)
          @subject = subject
          submatchers_match?
        end

        def description
          "only allow #{allowed_types} values for #{@attribute}"
        end

        def failure_message_for_should
          submatcher_failure_messages_for_should.last
        end

        def failure_message_for_should_not
          submatcher_failure_messages_for_should_not.last
        end

        private

        def add_disallow_value_matcher
          disallow_value_matcher = DisallowValueMatcher.new(NON_NUMERIC_VALUE).
            for(@attribute).
            with_message(:not_a_number)

          add_submatcher(disallow_value_matcher)
        end

        def add_submatcher(submatcher)
          @submatchers << submatcher
        end

        def submatchers_match?
          failing_submatchers.empty?
        end

        def submatcher_failure_messages_for_should
          failing_submatchers.map(&:failure_message_for_should)
        end

        def submatcher_failure_messages_for_should_not
          failing_submatchers.map(&:failure_message_for_should_not)
        end

        def failing_submatchers
          @failing_submatchers ||= @submatchers.select { |matcher| !matcher.matches?(@subject.dup) }
        end

        def allowed_types
          allowed = ['numeric'] + submatcher_allowed_types
          allowed.join(', ')
        end

        def submatcher_allowed_types
          @submatchers.map(&:allowed_types).reject(&:empty?)
        end
      end
    end
  end
end
