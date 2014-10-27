require_relative '../record_with_different_error_attribute_builder'
require_relative '../record_builder_with_i18n_validation_message'

module UnitTests
  module AllowValueMatcherHelpers
    def builder_for_record_with_different_error_attribute(options = {})
      RecordWithDifferentErrorAttributeBuilder.new(options)
    end

    def builder_for_record_with_different_error_attribute_using_i18n(options = {})
      builder = builder_for_record_with_different_error_attribute(options)
      RecordBuilderWithI18nValidationMessage.new(builder)
    end
  end
end
