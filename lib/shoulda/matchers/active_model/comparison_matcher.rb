require 'active_support/core_ext/module/delegation'

module Shoulda
  module Matchers
    module ActiveModel
      # @private
      class ComparisonMatcher < ValidationMatcher
        ERROR_MESSAGES = {
          :> => {
            label: :greater_than,
            assertions: [false, false, true],
          },
          :>= => {
            label: :greater_than_or_equal_to,
            assertions: [false, true, true],
          },
          :< => {
            label: :less_than,
            assertions: [true, false, false],
          },
          :<= => {
            label: :less_than_or_equal_to,
            assertions: [true, true, false],
          },
          :== => {
            label: :equal_to,
            assertions: [false, true, false],
          },
          :!= => {
            label: :other_than,
            assertions: [true, false, true],
          },
        }.freeze

        delegate :failure_message, :failure_message_when_negated, to: :comparison_submatchers

        def initialize(matcher, value, operator)
          super(nil)
          unless matcher.respond_to? :diff_to_compare
            raise ArgumentError, 'matcher is invalid'
          end

          @matcher = matcher
          @value = value
          @operator = operator
          @message = ERROR_MESSAGES[operator][:label]
        end

        def simple_description
          description = ''

          if expects_strict?
            description = ' strictly'
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
          comparison_submatchers.matches?(subject)
        end

        def comparison_description
          "#{comparison_expectation} #{@value}"
        end

        def comparison_submatchers
          @_comparison_submatchers ||=
            NumericalityMatchers::Submatchers.new(build_comparison_submatchers)
        end

        private

        def build_comparison_submatchers
          comparison_combos.map do |diff, submatcher_method_name|
            matcher = __send__(submatcher_method_name, diff, nil)
            matcher.with_message(@message, values: { count: option_value })
            matcher
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
          ERROR_MESSAGES[@operator][:assertions]
        end

        def option_value
          if defined?(@_option_value)
            @_option_value
          else
            @_option_value =
              case @value
              when Proc then @value.call(@subject)
              when Symbol then @subject.send(@value)
              else @value
              end
          end
        end

        def diffs_to_compare
          diff_to_compare = @matcher.diff_to_compare
          values = case option_value
                   when String then diffs_when_string(diff_to_compare)
                   else [-1, 0, 1].map { |sign| option_value + (diff_to_compare * sign) }
                   end

          if @matcher.given_numeric_column?
            values
          else
            values.map(&:to_s)
          end
        end

        def diffs_when_string(diff_to_compare)
          [-1, 0, 1].map do |sign|
            option_value[0..-2] + (option_value[-1].ord + diff_to_compare * sign).chr
          end
        end

        def comparison_expectation
          ERROR_MESSAGES[@operator][:label].to_s.tr('_', ' ')
        end
      end
    end
  end
end
