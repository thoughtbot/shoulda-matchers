module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      module NumericalityMatchers
        # Examples:
        #   it { should validate_numericality_of(:attr).
        #                 is_greater_than(6).
        #                 less_than(20)...(and so on) }
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
          end

          def for(attribute)
            @attribute = attribute
            self
          end

          def matches?(subject)
            @subject = subject
            all_bounds_correct?
          end

          def with_message(message)
            @message = message
          end

          def comparison_description
            "#{expectation} #{@value}"
          end

          private

          def comparison_combos
            allow = :allows_value_of
            disallow = :disallows_value_of
            checker_types =
              case @operator
                when :> then [allow, disallow, disallow]
                when :>= then [allow, allow, disallow]
                when :== then [disallow, allow, disallow]
                when :< then [disallow, disallow, allow]
                when :<= then [disallow, allow, allow]
              end
            diffs_to_compare.zip(checker_types)
          end

          def diffs_to_compare
            diff = @numericality_matcher.diff_to_compare
            [diff, 0, -diff]
          end

          def expectation
            case @operator
              when :> then "greater than"
              when :>= then "greater than or equal to"
              when :== then "equal to"
              when :< then "less than"
              when :<= then "less than or equal to"
            end
          end

          def all_bounds_correct?
            @comparison_combos.all? do |diff, checker_type|
              __send__(checker_type, @value + diff) do |matcher|
                matcher.with_message(@message, values: { count: @value })
              end
            end
          end
        end
      end
    end
  end
end
