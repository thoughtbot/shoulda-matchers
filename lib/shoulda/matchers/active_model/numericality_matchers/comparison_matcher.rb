module Shoulda
  module Matchers
    module ActiveModel
      module NumericalityMatchers
        # @private
        class ComparisonMatcher < ValidationMatcher
          ERROR_MESSAGES = {
            :> => :greater_than,
            :>= => :greater_than_or_equal_to,
            :< => :less_than,
            :<= => :less_than_or_equal_to,
            :== => :equal_to
          }

          def initialize(numericality_matcher, value, operator)
            super(nil)
            unless numericality_matcher.respond_to? :diff_to_compare
              raise ArgumentError, 'numericality_matcher is invalid'
            end
            @numericality_matcher = numericality_matcher
            @value = value
            @operator = operator
            @message = ERROR_MESSAGES[operator]
          end

          def simple_description
            description = ''

            if expects_strict?
              description << ' strictly'
            end

            description +
              "disallow :#{attribute} from being a number that is not " +
              "#{comparison_expectation} #{@value}"
          end

          def for(attribute)
            @attribute = attribute
            self
          end

          def with_message(message)
            @expects_custom_validation_message = true
            @message = message
            self
          end

          def expects_custom_validation_message?
            @expects_custom_validation_message
          end

          def matches?(subject)
            @subject = subject
            all_bounds_correct?
          end

          def failure_message
            last_failing_submatcher.failure_message
          end

          def failure_message_when_negated
            last_failing_submatcher.failure_message_when_negated
          end

          def comparison_description
            "#{comparison_expectation} #{@value}"
          end

          private

          def all_bounds_correct?
            failing_submatchers.empty?
          end

          def failing_submatchers
            submatchers_and_results.
              select { |x| !x[:matched] }.
              map { |x| x[:matcher] }
          end

          def last_failing_submatcher
            failing_submatchers.last
          end

          def submatchers
            @_submatchers ||=
              comparison_combos.map do |diff, submatcher_method_name|
                matcher = __send__(submatcher_method_name, diff, nil)
                matcher.with_message(@message, values: { count: @value })
                matcher
              end
          end

          def submatchers_and_results
            @_submatchers_and_results ||=
              submatchers.map do |matcher|
                { matcher: matcher, matched: matcher.matches?(@subject) }
              end
          end

          def comparison_combos
            diffs_to_compare.zip(submatcher_method_names)
          end

          def submatcher_method_names
            assertions.map do |value|
              if value
                :allow_value_matcher
              else
                :disallow_value_matcher
              end
            end
          end

          def assertions
            case @operator
            when :>
              [false, false, true]
            when :>=
              [false, true, true]
            when :==
              [false, true, false]
            when :<
              [true, false, false]
            when :<=
              [true, true, false]
            end
          end

          def diffs_to_compare
            diff_to_compare = @numericality_matcher.diff_to_compare
            values = [-1, 0, 1].map { |sign| @value + (diff_to_compare * sign) }

            if @numericality_matcher.given_numeric_column?
              values
            else
              values.map(&:to_s)
            end
          end

          def comparison_expectation
            case @operator
              when :> then "greater than"
              when :>= then "greater than or equal to"
              when :== then "equal to"
              when :< then "less than"
              when :<= then "less than or equal to"
            end
          end
        end
      end
    end
  end
end
