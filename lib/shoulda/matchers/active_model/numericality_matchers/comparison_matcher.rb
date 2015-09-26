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
            unless numericality_matcher.respond_to? :diff_to_compare
              raise ArgumentError, 'numericality_matcher is invalid'
            end
            @numericality_matcher = numericality_matcher
            @value = value
            @operator = operator
            @message = ERROR_MESSAGES[operator]
            @comparison_combos = comparison_combos
            @strict = false
          end

          def description
            message = "validate that #{@attribute} is #{comparison_expectation} #{@value}"

            if @strict
              message << " strictly"
            end

            message
          end

          def for(attribute)
            @attribute = attribute
            self
          end

          def with_message(message)
            @message = message
            self
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
                matcher = __send__(
                  submatcher_method_name,
                  (@value + diff).to_s,
                  nil
                )
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
            diff = @numericality_matcher.diff_to_compare
            [-diff, 0, diff]
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
