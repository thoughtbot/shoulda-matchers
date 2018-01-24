module Shoulda
  module Matchers
    module ActiveModel
      # @private
      class DisallowValueMatcher < AllowOrDisallowValueMatcher
        # def description_of_values_to_disallow
           # inspected_values_to_set
        # end

        def aberration_description
          if was_negated?
            positive_aberration_description
          else
            negative_aberration_description
          end
        end

        def matches?(subject)
          super(subject)

          @result = run(:first_to_unexpectedly_not_fail)
          @result.nil?
        end

        # def does_not_match?(subject)
          # super(subject)

          # @result = run(:first_to_unexpectedly_not_pass)
          # !@result.nil?
        # end

        def failure_message
          negative_failure_message
        end

        def failure_message_when_negated
          positive_failure_message
        end

        protected

        def expectation_negated?
          !was_negated?
        end
      end
    end
  end
end
