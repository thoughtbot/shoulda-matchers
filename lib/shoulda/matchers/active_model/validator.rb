module Shoulda
  module Matchers
    module ActiveModel
      # @private
      class Validator
        include Helpers

        def initialize(record, attribute, options = {})
          @record = record
          @attribute = attribute
          @context = options[:context]
          @expects_strict = options[:expects_strict]
          @expected_message = options[:expected_message]

          @_validation_result = nil
          @captured_validation_exception = false
        end

        def passes?
          perform_validation
          validation_messages.none?
        end

        def fails?
          perform_validation
          validation_messages_match?
        end

        def captured_validation_exception?
          @captured_validation_exception
        end

        def validation_message_type_matches?
          expects_strict? == captured_validation_exception?
        end

        def has_matching_validation_messages?
          matched_validation_messages.compact.any?
        end

        def all_formatted_validation_error_messages
          format_validation_errors(all_validation_errors)
        end

        def validation_exception_message
          validation_result[:validation_exception_message]
        end

        def pretty_print(pp)
          Shoulda::Matchers::Util.pretty_print(self, pp, {
            record: record,
            attribute: attribute,
            expects_strict: expects_strict?,
            validation_result: validation_result,
            matched_validation_messages: matched_validation_messages,
          })
        end

        protected

        attr_reader :attribute, :context, :record, :validation_result

        private

        def expects_strict?
          @expects_strict
        end

        def perform_validation
          if context
            record.valid?(context)
          else
            record.valid?
          end

          all_validation_errors = record.errors.dup

          validation_error_messages =
            if record.errors.respond_to?(:[])
              record.errors[attribute]
            else
              record.errors.on(attribute)
            end

          @validation_result = {
            all_validation_errors: all_validation_errors,
            validation_error_messages: validation_error_messages,
            validation_exception_message: nil,
          }
        rescue ::ActiveModel::StrictValidationFailed => exception
          @captured_validation_exception = true
          @validation_result = {
            all_validation_errors: nil,
            validation_error_messages: [],
            validation_exception_message: exception.message,
          }
        end

        def validation_messages_match?
          validation_message_type_matches? && has_matching_validation_messages?
        end

        def validation_messages
          if expects_strict?
            [validation_exception_message]
          else
            validation_error_messages
          end
        end

        def matched_validation_messages
          if @expected_message
            validation_messages.grep(@expected_message)
          else
            validation_messages
          end
        end

        def all_validation_errors
          if validation_result
            validation_result[:all_validation_errors]
          else
            []
          end
        end

        def validation_error_messages
          if validation_result
            validation_result[:validation_error_messages]
          else
            []
          end
        end
      end
    end
  end
end
