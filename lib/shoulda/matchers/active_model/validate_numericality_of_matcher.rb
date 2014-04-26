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
      # * <tt>allow_nil</tt> - allows nil values
      #
      # Examples:
      #   it { should validate_numericality_of(:price) }
      #   it { should validate_numericality_of(:age).only_integer }
      #   it { should validate_numericality_of(:frequency).odd }
      #   it { should validate_numericality_of(:frequency).even }
      #   it { should validate_numericality_of(:rank).is_less_than_or_equal_to(10).allow_nil }
      #
      def validate_numericality_of(attr)
        ValidateNumericalityOfMatcher.new(attr)
      end

      class ValidateNumericalityOfMatcher
        NUMERIC_NAME = 'numbers'
        NON_NUMERIC_VALUE = 'abcd'
        DEFAULT_DIFF_TO_COMPARE = 1

        attr_reader :diff_to_compare

        def initialize(attribute)
          @attribute = attribute
          @submatchers = []
          @diff_to_compare = DEFAULT_DIFF_TO_COMPARE
          add_disallow_value_matcher
        end

        def only_integer
          prepare_submatcher(
            NumericalityMatchers::OnlyIntegerMatcher.new(@attribute)
          )
          self
        end

        def allow_nil
          prepare_submatcher(
            AllowValueMatcher.new(nil)
              .for(@attribute)
              .with_message(:not_a_number)
          )
          self
        end

        def odd
          prepare_submatcher(
            NumericalityMatchers::OddNumberMatcher.new(@attribute)
          )
          self
        end

        def even
          prepare_submatcher(
            NumericalityMatchers::EvenNumberMatcher.new(@attribute)
          )
          self
        end

        def is_greater_than(value)
          prepare_submatcher(comparison_matcher_for(value, :>).for(@attribute))
          self
        end

        def is_greater_than_or_equal_to(value)
          prepare_submatcher(comparison_matcher_for(value, :>=).for(@attribute))
          self
        end

        def is_equal_to(value)
          prepare_submatcher(comparison_matcher_for(value, :==).for(@attribute))
          self
        end

        def is_less_than(value)
          prepare_submatcher(comparison_matcher_for(value, :<).for(@attribute))
          self
        end

        def is_less_than_or_equal_to(value)
          prepare_submatcher(comparison_matcher_for(value, :<=).for(@attribute))
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
          "only allow #{allowed_types} for #{@attribute}#{comparison_descriptions}"
        end

        def failure_message
          submatcher_failure_messages_for_should.last
        end
        alias failure_message_for_should failure_message

        def failure_message_when_negated
          submatcher_failure_messages_for_should_not.last
        end
        alias failure_message_for_should_not failure_message_when_negated

        private

        def add_disallow_value_matcher
          disallow_value_matcher = DisallowValueMatcher.new(NON_NUMERIC_VALUE).
            for(@attribute).
            with_message(:not_a_number)

          add_submatcher(disallow_value_matcher)
        end

        def prepare_submatcher(submatcher)
          add_submatcher(submatcher)
          if submatcher.respond_to?(:diff_to_compare)
            update_diff_to_compare(submatcher)
          end
        end

        def comparison_matcher_for(value, operator)
          NumericalityMatchers::ComparisonMatcher
            .new(self, value, operator)
            .for(@attribute)
        end

        def add_submatcher(submatcher)
          @submatchers << submatcher
        end

        def update_diff_to_compare(matcher)
          @diff_to_compare = [@diff_to_compare, matcher.diff_to_compare].max
        end

        def submatchers_match?
          failing_submatchers.empty?
        end

        def submatcher_failure_messages_for_should
          failing_submatchers.map(&:failure_message)
        end

        def submatcher_failure_messages_for_should_not
          failing_submatchers.map(&:failure_message_when_negated)
        end

        def failing_submatchers
          @failing_submatchers ||= @submatchers.select { |matcher| !matcher.matches?(@subject) }
        end

        def allowed_types
          allowed_array = submatcher_allowed_types
          allowed_array.empty? ? NUMERIC_NAME : allowed_array.join(', ')
        end

        def submatcher_allowed_types
          @submatchers.inject([]){|m, s| m << s.allowed_type if s.respond_to?(:allowed_type); m }
        end

        def comparison_descriptions
          description_array = submatcher_comparison_descriptions
          description_array.empty? ? '' : ' which are ' + submatcher_comparison_descriptions.join(' and ')
        end

        def submatcher_comparison_descriptions
          @submatchers.inject([]) do |arr, submatcher|
            if submatcher.respond_to? :comparison_description
              arr << submatcher.comparison_description
            end
            arr
          end
        end
      end
    end
  end
end
