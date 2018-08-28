module Shoulda
  module Matchers
    module ActiveModel
      class AllowOrDisallowValueMatcher
        # @private
        class BuildNegativeAberrationDescription
          def self.call(validator)
            new(validator).call
          end

          def initialize(validator)
            @validator = validator
          end

          def call
            if validator.validation_message_type_matches?
              description_for_when_message_type_matches
            elsif validator.captured_validation_exception?
              description_for_unexpected_validation_exception
            elsif validator.has_any_validation_errors?
              description_for_unexpected_validation_errors
            else
              'However, it did not fail validation.'
            end
          end

          private

          attr_reader :validator

          private

          def description_for_when_message_type_matches
            if validator.has_validation_messages?
              description_comparing_messages
            elsif validator.expects_strict?
              'However, no such exception was raised.'
            else
              ''.tap do |str|
                str << 'However, no such error was found on '
                str << ":#{validator.attribute}"

                if validator.context.present?
                  str << ' there. (Perhaps the validation was run under a '
                  str << 'different context?)'
                else
                  str << '.'
                end
              end
            end
          end

          def description_comparing_messages
            ''.tap do |str|
              str << 'The record did fail validation, but '

              if validator.captured_validation_exception?
                str << 'the exception description was '
                str << validator.validation_exception_description.inspect
                str << ' instead.'
              else
                str << 'these errors were found on '
                str << ":#{validator.attribute} instead:\n\n"
                str << validator.formatted_validation_messages
              end
            end
          end

          def description_for_unexpected_validation_exception
            'The record did indeed fail validation, but it ' +
              'raised a validation exception ' +
              validator.validation_exception_message.inspect +
              ' instead.'
          end

          def description_for_unexpected_validation_errors
            'The record did indeed fail validation, but instead of ' +
              'raising an exception, it produced errors on ' +
              "these attributes:\n\n" +
              validator.all_formatted_validation_errors
          end
        end
      end
    end
  end
end
