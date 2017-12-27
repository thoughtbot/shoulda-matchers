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
            :== => :equal_to,
          }.freeze

          def initialize(numericality_matcher, attribute, value, operator)
            super(attribute)

            if !numericality_matcher.respond_to?(:diff_to_compare)
              raise ArgumentError.new(
                'The given numericality matcher does not respond to ' +
                ':diff_to_compare',
              )
            end

            @numericality_matcher = numericality_matcher
            @value = value
            @operator = operator
            @message = ERROR_MESSAGES.fetch(operator)
            # @comparison_expectation = COMPARISON_EXPECTATIONS.fetch(operator)
          end

          # def comparison_description
            # "#{comparison_expectation} #{value}"
          # end

          protected

          def add_submatchers
            comparison_tuples.each do |diff, add_submatcher_method_name|
              __send__(add_submatcher_method_name, diff, nil) do |matcher|
                matcher.with_message(message, values: { count: value })
              end
            end
          end

          private

          attr_reader :numericality_matcher, :value, :operator, :message,
            :comparison_expectation

          def comparison_tuples
            diffs_to_compare.zip(add_submatcher_method_names)
          end

          def diffs_to_compare
            diff_to_compare = numericality_matcher.diff_to_compare
            values = [-1, 0, 1].map { |sign| value + (diff_to_compare * sign) }

            if numericality_matcher.given_numeric_column?
              values
            else
              values.map(&:to_s)
            end
          end

          def add_submatcher_method_names
            case operator
            when :>
              [
                :add_submatcher_disallowing,
                :add_submatcher_disallowing,
                :add_submatcher_allowing,
              ]
            when :>=
              [
                :add_submatcher_disallowing,
                :add_submatcher_allowing,
                :add_submatcher_allowing,
              ]
            when :==
              [
                :add_submatcher_disallowing,
                :add_submatcher_allowing,
                :add_submatcher_disallowing,
              ]
            when :<
              [
                :add_submatcher_allowing,
                :add_submatcher_disallowing,
                :add_submatcher_disallowing,
              ]
            when :<=
              [
                :add_submatcher_allowing,
                :add_submatcher_allowing,
                :add_submatcher_disallowing,
              ]
            end
          end
        end
      end
    end
  end
end
