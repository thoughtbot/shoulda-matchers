module Shoulda
  module Matchers
    module ActiveModel
      # @private
      class DisallowValueMatcher < AllowOrDisallowValueMatcher
        # def description_of_values_to_disallow
           # inspected_values_to_set
        # end

        def expectation
          ValidationMatcher::BuildExpectation.call(self, 'be invalid')
        end

        def aberration_description
          if was_negated?
            validator = result.validator

            description = 'However, '

            if validator.captured_validation_exception?
              description << ' it raised a validation exception with the message '
              description << validator.validation_exception_message.inspect
              description << '.'
            else
              description << " it produced these validation errors:\n\n"
              description << validator.all_formatted_validation_error_messages
            end

            description
          else
            'However, it was valid.'
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
      end
    end
  end
end
