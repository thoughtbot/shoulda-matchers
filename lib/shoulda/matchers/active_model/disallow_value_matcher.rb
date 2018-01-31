module Shoulda
  module Matchers
    module ActiveModel
      # @private
      class DisallowValueMatcher < AllowOrDisallowValueMatcher
        def aberration_description
          if was_negated?
            positive_aberration_description
          else
            negative_aberration_description
          end
        end

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

        def method_to_run_for_matching
          :first_to_unexpectedly_not_pass
        end
      end
    end
  end
end
