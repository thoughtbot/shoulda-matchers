module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:

      # Examples:
      #   it { should validate_numericality_of(:attr).
      #                 is_greater_than(6).
      #                 less_than(20)...(and so on) }


      class ComparisonMatcher

        def initialize(value, operator)
          @value = value
          @options = { :operator => operator }
        end

        def for(attribute)
          @attribute = attribute
          self
        end

        def matches?(subject)
          @subject = subject
          val = @subject.send(@attribute)
          val.send(@options[:operator], @value) unless val.nil?
        end

        def failure_message
          "Expected #{@subject.send(@attribute)} to be #{expectation} #{@value}"
        end


        private

        def expectation
          case @options[:operator]
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
