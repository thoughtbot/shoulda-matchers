module Shoulda
  module Matchers
    module ActiveModel
      module Numericality
        # @private
        class ComparisonMatcher
          ERROR_MESSAGES = {
            :> => :greater_than,
            :>= => :greater_than_or_equal_to,
            :< => :less_than,
            :<= => :less_than_or_equal_to,
            :== => :equal_to
          }

          def initialize(numericality_matcher, value, operator)
            @numericality_matcher = numericality_matcher
            @value = value
            @operator = operator
            @message = ERROR_MESSAGES[operator]
            @submatchers = MatcherCollection.new.tap do |submatchers|
              submatchers.configure do |matcher|
                matcher.with_message(message, values: { count: value })
              end

              comparison_combos.each do |diff, matcher_class|
                submatchers.add(matcher_class, value + diff)
              end
            end
          end

          def for(attribute)
            @attribute = attribute
            self
          end

          def on(context)
            submatchers.invoke(:on, context)
          end

          def strict
            submatchers.invoke(:strict)
          end

          def with_message(message)
            submatchers.invoke(:with_message, message)
          end

          def matches?(subject)
            submatchers.matches?(subject)
          end

          def comparison_description
            "#{expectation} #{value}"
          end

          protected

          attr_reader :numericality_matcher, :value, :operator, :message,
            :submatchers, :subject

          private

          delegate :diff_to_compare, to: :numericality_matcher

          def comparison_combos
            diffs_to_compare.zip(checker_types)
          end

          def diffs_to_compare
            [diff_to_compare, 0, -diff_to_compare]
          end

          def checker_types
            case operator
            when :>
              [:allows_value_of, :disallows_value_of, :disallows_value_of]
            when :>=
              [:allows_value_of, :allows_value_of, :disallows_value_of]
            when :==
              [:disallows_value_of, :allows_value_of, :disallows_value_of]
            when :<
              [:disallows_value_of, :disallows_value_of, :allows_value_of]
            when :<=
              [:disallows_value_of, :allows_value_of, :allows_value_of]
            end
          end

          def expectation
            case operator
              when :> then 'greater than'
              when :>= then 'greater than or equal to'
              when :== then 'equal to'
              when :< then 'less than'
              when :<= then 'less than or equal to'
            end
          end
        end
      end
    end
  end
end
