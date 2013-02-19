module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      # Examples:
      #   it { should validate_numericality_of(:attr).
      #                 is_greater_than(6).
      #                 less_than(20)...(and so on) }
      class ComparisonMatcher < ValidationMatcher
        def initialize(value, operator)
          @value = value
          @operator = operator
        end

        def for(attribute)
          @attribute = attribute
          self
        end

        def matches?(subject)
          @subject = subject
          disallows_value_of(value_to_compare)
        end

        def allowed_types
          'integer'
        end

        private

        def value_to_compare
          case @operator
            when :> then [@value, @value - 1].sample
            when :>= then @value - 1
            when :== then @value
            when :< then [@value, @value + 1].sample
            when :<= then @value + 1
          end
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
      end
    end
  end
end
