module Shoulda
  module Matchers
    module ActiveModel
      # @private
      class DisallowValueMatcher < AllowOrDisallowValueMatcher
        # def matches?(subject)
          # @was_negated = true
          # matches_or_does_not_match?(subject)
        # end

        # def does_not_match?(subject)
          # @was_negated = false
          # matches_or_does_not_match?(subject)
        # end

        def failure_message
          negative_failure_message
        end

        def failure_message_when_negated
          positive_failure_message
        end

        def aberration_description
          negative_aberration_description
        end

        def aberration_description_when_negated
          positive_aberration_description
        end

        protected

        def inverted?
          true
        end

        def method_to_find_first_non_match
          if was_negated?
            :first_to_produce_validation_messages
          else
            :first_where_validation_messages_do_not_match
          end
        end
      end
    end
  end
end
