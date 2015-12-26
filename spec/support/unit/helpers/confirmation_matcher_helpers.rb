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

    def active_model_validating_confirmation_of(attr)
      active_model_with([attr, "#{attr}_confirmation"]) do
        validates_confirmation_of attr
      end
    end

    def active_model_with(attributes, &block)
      define_active_model_class('Example', accessors: attributes, &block).new
    end
  end
end
