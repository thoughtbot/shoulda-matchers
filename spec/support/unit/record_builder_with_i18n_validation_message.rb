require 'delegate'

module UnitTests
  class RecordBuilderWithI18nValidationMessage < SimpleDelegator
    def initialize(builder, options = {})
      super(builder)
      @options = default_options.merge(options)
      builder.message = validation_message_key
    end

    def validation_message_key
      options[:validation_message_key]
    end

    protected

    attr_reader :builder, :options

    private

    def model
      @_model ||= super.tap do |model|
        stub_validation_messages
      end
    end

    def stub_validation_messages
      stub_default_validation_message
      stub_attribute_specific_validation_message
    end

    def stub_default_validation_message
      keys = [
        'activerecord.errors.messages',
        validation_message_key
      ]

      I18nFaker.stub_translation(keys, default_message)
    end

    def stub_attribute_specific_validation_message
      keys = [
        'activerecord.errors',
        "models.#{builder.model_name.to_s.underscore}",
        "attributes.#{builder.attribute_that_receives_error}",
        validation_message_key
      ]

      I18nFaker.stub_translation(
        keys,
        message_for_attribute_that_receives_error
      )
    end

    def default_message
      'the wrong message'
    end

    def message_for_attribute_that_receives_error
      'the right message'
    end

    def default_options
      {
        validation_message_key: :validation_message_key
      }
    end
  end
end
