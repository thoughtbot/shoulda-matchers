module Shoulda
  module Matchers
    module ActiveModel
      # Finds message information from exceptions thrown by #valid?
      class ExceptionMessageFinder
        def initialize(instance, attribute)
          @instance = instance
          @attribute = attribute
        end

        def allow_description(allowed_values)
          "doesn't raise when #{@attribute} is set to #{allowed_values}"
        end

        def messages_description
          if has_messages?
            messages.join
          else
            'no exception'
          end
        end

        def has_messages?
          messages.any?
        end

        def messages
          @messages ||= validate_and_rescue
        end

        def source_description
          'exception'
        end

        def expected_message_from(attribute_message)
          "#{human_attribute_name} #{attribute_message}"
        end

        private

        def validate_and_rescue
          @instance.valid?
          []
        rescue ::ActiveModel::StrictValidationFailed => exception
          [exception.message]
        end

        def human_attribute_name
          @instance.class.human_attribute_name(@attribute)
        end
      end

    end
  end
end


