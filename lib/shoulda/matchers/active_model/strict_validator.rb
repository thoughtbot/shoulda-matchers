module Shoulda
  module Matchers
    module ActiveModel
      # @private
      module StrictValidator
        def allow_description(allowed_values)
          "doesn't raise when #{attribute} is set to #{allowed_values}"
        end

        def expected_message_from(attribute_message)
          "#{human_attribute_name} #{attribute_message}"
        end

        def formatted_messages
          [messages.first.message]
        end

        def messages_description
          if has_messages?
            ': ' + messages.first.message.inspect
          else
            ' no exception'
          end
        end

        def expected_messages_description(expected_message)
          if expected_message
            "exception to include #{expected_message.inspect}"
          else
            'an exception to have been raised'
          end
        end

        protected

        def collect_messages
          validation_exceptions
        end

        private

        def validation_exceptions
          record.valid?(context)
          []
        rescue ::ActiveModel::StrictValidationFailed => exception
          [exception]
        end
      end
    end
  end
end
