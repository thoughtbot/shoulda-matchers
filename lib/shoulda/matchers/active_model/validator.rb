module Shoulda
  module Matchers
    module ActiveModel
      # @private
      class Validator
        include Helpers

        attr_writer :attribute, :context, :record

        def initialize
          reset
        end

        def reset
          @messages = nil
        end

        def strict=(strict)
          @strict = strict

          if strict
            extend StrictValidator
          end
        end

        def capture_range_error(exception)
          @captured_range_error = exception
          extend ValidatorWithCapturedRangeError
        end

        def allow_description(allowed_values)
          "allow #{attribute} to be set to #{allowed_values}"
        end

        def expected_message_from(attribute_message)
          attribute_message
        end

        def messages
          @messages ||= collect_messages
        end

        def formatted_messages
          messages
        end

        def has_messages?
          messages.any?
        end

        def messages_description
          if has_messages?
            " errors:\n#{pretty_error_messages(record)}"
          else
            ' no errors'
          end
        end

        def expected_messages_description(expected_message)
          if expected_message
            "errors to include #{expected_message.inspect}"
          else
            'errors'
          end
        end

        def captured_range_error?
          !!captured_range_error
        end

        protected

        attr_reader :attribute, :context, :strict, :record,
          :captured_range_error

        def collect_messages
          validation_errors
        end

        private

        def strict?
          !!@strict
        end

        def collect_errors_or_exceptions
          collect_messages
        rescue RangeError => exception
          capture_range_error(exception)
          []
        end

        def validation_errors
          if context
            record.valid?(context)
          else
            record.valid?
          end

          if record.errors.respond_to?(:[])
            record.errors[attribute]
          else
            record.errors.on(attribute)
          end
        end

        def human_attribute_name
          record.class.human_attribute_name(attribute)
        end
      end
    end
  end
end
