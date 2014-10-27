require_relative '../record_validating_confirmation_builder'
require_relative '../record_builder_with_i18n_validation_message'

module UnitTests
  module ConfirmationMatcherHelpers
    def builder_for_record_validating_confirmation(options = {})
      RecordValidatingConfirmationBuilder.new(options)
    end

    def builder_for_record_validating_confirmation_with_18n_message(options = {})
      builder = builder_for_record_validating_confirmation(options)
      RecordBuilderWithI18nValidationMessage.new(builder,
        validation_message_key: :confirmation
      )
    end
  end
end
