module Shoulda
  module Matchers
    module ActiveModel

      # Finds message information from a model's #errors method.
      class ValidationMessageFinder
        include Helpers

        def initialize(instance, attribute)
          @instance = instance
          @attribute = attribute
        end

        def allow_description(allowed_values)
          "allow #{@attribute} to be set to #{allowed_values}"
        end

        def expected_message_from(attribute_message)
          attribute_message
        end

        def has_messages?
          errors.present?
        end

        def source_description
          'errors'
        end

        def messages_description
          if errors.empty?
            'no errors'
          else
            "errors: #{pretty_error_messages(validated_instance)}"
          end
        end

        def messages
          Array.wrap(messages_for_attribute)
        end

        private

        def messages_for_attribute
          if errors.respond_to?(:[])
            errors[@attribute]
          else
            errors.on(@attribute)
          end
        end

        def errors
          validated_instance.errors
        end

        def validated_instance
          @validated_instance ||= validate_instance
        end

        def validate_instance
          @instance.valid?
          @instance
        end
      end

    end
  end
end

