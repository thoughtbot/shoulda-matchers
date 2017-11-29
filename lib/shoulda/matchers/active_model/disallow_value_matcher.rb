module Shoulda
  module Matchers
    module ActiveModel
      # @private
      class DisallowValueMatcher < AllowOrDisallowValueMatcher
        def simple_description
          "fail validation when :#{attribute_to_set} is set to " +
            "#{inspected_values_to_set}"
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
