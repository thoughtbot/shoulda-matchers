module Shoulda
  module Matchers
    module ActiveModel
      # @private
      class DisallowValueMatcher < AllowOrDisallowValueMatcher
        # def description_of_values_to_disallow
           # inspected_values_to_set
        # end

        def expectation
          error_type_clause =
            if expects_strict?
              'raising an exception'
            else
              'placing the error'
            end

          if expected_message
            preface =
              "to fail validation by #{error_type_clause} " +
              "#{expected_message.inspect} on " +
              ":#{attribute_to_check_message_against}"

            ValidationMatcher::BuildExpectation.call(
              self,
              preface,
              state: :invalid,
            )
          else
            ValidationMatcher::BuildExpectation.call(
              self,
              'to be invalid',
              state: :invalid,
            )
          end
        end

        def aberration_description
          if was_negated?
            negative_aberration_description
          else
            positive_aberration_description
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
