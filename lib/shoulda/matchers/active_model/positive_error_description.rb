module Shoulda
  module Matchers
    module ActiveModel
      class PositiveErrorDescription
        def initialize(instance, attribute, value, expected_message)
          @instance = instance
          @attribute = attribute
          @value = value
          @expected_message = expected_message
        end

        def matches?
          if @expected_message
            error_message_matches_string? || error_message_matches_regexp?
          else
            errors_for_attribute.any?
          end
        end

        def matched_error
          if @expected_message
            error_matching_expected || ""
          else
            first_error_message
          end
        end

        private

        def error_message_matches_string?
          if @expected_message.is_a? String
            errors_for_attribute.include?(@expected_message)
          end
        end

        def error_message_matches_regexp?
          if @expected_message.is_a? Regexp
            errors_for_attribute.any? do |error|
              @expected_message =~ error
            end
          end
        end

        def error_matching_expected
          errors_for_attribute.select do |error|
            @expected_message.match(error)
          end.first
        end

        def first_error_message
          errors_for_attribute.first.to_s
        end

        def errors_for_attribute
          valid?
          Array.wrap(@instance.errors[@attribute])
        end

        def valid?
          @instance.send("#{@attribute}=", @value)
          @instance.valid?
        end
      end
    end
  end
end
