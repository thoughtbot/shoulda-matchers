require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateConfirmationOfMatcher, type: :model do
  include UnitTests::ConfirmationMatcherHelpers

  context '#description' do
    it 'states that the confirmation must match its base attribute' do
      builder = builder_for_record_validating_confirmation
      message = "require #{builder.confirmation_attribute} to match #{builder.attribute_to_confirm}"
      matcher = described_class.new(builder.attribute_to_confirm)
      expect(matcher.description).to eq(message)
    end
  end

  context 'when the model has a confirmation validation' do
    it 'passes' do
      builder = builder_for_record_validating_confirmation
      expect(builder.record).
        to validate_confirmation_of(builder.attribute_to_confirm)
    end

    context 'when a nil message is specified' do
      it 'ignores it' do
        builder = builder_for_record_validating_confirmation
        expect(builder.record).
          to validate_confirmation_of(builder.attribute_to_confirm).
          with_message(nil)
      end
    end
  end

  context 'when the model does not have a confirmation validation' do
    it 'fails' do
      model = define_model(:example, attribute_to_confirm: :string)
      record = model.new
      expect(record).not_to validate_confirmation_of(:attribute_to_confirm)
    end
  end

  context 'when both validation and matcher specify a custom message' do
    it 'passes when the expected and actual messages match' do
      builder = builder_for_record_validating_confirmation(message: 'custom')
      expect(builder.record).
        to validate_confirmation_of(builder.attribute_to_confirm).
        with_message(/custom/)
    end

    it 'fails when the expected and actual messages do not match' do
      builder = builder_for_record_validating_confirmation(message: 'custom')
      expect(builder.record).
        not_to validate_confirmation_of(builder.attribute_to_confirm).
        with_message(/wrong/)
    end
  end

  context 'when the validation specifies a message via i18n' do
    it 'passes' do
      builder = builder_for_record_validating_confirmation_with_18n_message
      expect(builder.record).
        to validate_confirmation_of(builder.attribute_to_confirm)
    end
  end

  context 'when the writer method for the attribute changes incoming values' do
    context 'and the matcher knows nothing of this' do
      it 'raises a CouldNotSetAttributeError' do
        builder = builder_for_record_validating_confirmation

        builder.model.class_eval do
          def password=(value)
            super(value.upcase)
          end
        end

        assertion = lambda do
          expect(builder.record).to validate_confirmation_of(:password)
        end

        expect(&assertion).to raise_error(
          Shoulda::Matchers::ActiveModel::AllowValueMatcher::CouldNotSetAttributeError
        )
      end
    end

    context 'and the matcher knows how given values get changed' do
      it 'accepts (and not raise an error)' do
        model = define_model_validating_confirmation(
          attribute_name: :terms_of_service
        )

        model.class_eval do
          undef_method :terms_of_service=

          def terms_of_service=(value)
            if value
              @terms_of_service = value
            else
              @terms_of_service = "something different"
            end
          end
        end

        expect(model.new).
          to validate_acceptance_of(:terms_of_service).
          converting_values(false => "something different")
      end
    end
  end
end
