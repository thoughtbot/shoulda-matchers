require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateConfirmationOfMatcher, type: :model do
  include UnitTests::ConfirmationMatcherHelpers

  def self.available_column_types
    [
      :string,
      :text,
      :integer,
      :float,
      :decimal,
      :datetime,
      :timestamp,
      :time,
      :date,
      :binary
    ]
  end

  context '#description' do
    it 'states that the confirmation must match its base attribute' do
      builder = builder_for_record_validating_confirmation
      message = "validate that #{builder.confirmation_attribute} matches #{builder.attribute_to_confirm}"
      matcher = described_class.new(builder.attribute_to_confirm)
      expect(matcher.description).to eq(message)
    end
  end

  context 'when the model has a confirmation validation' do
    available_column_types.each do |column_type|
      it "passes when the column is of type #{column_type}" do
        builder = builder_for_record_validating_confirmation(
          column_type: column_type
        )
        expect(builder.record).
          to validate_confirmation_of(builder.attribute_to_confirm)
      end
    end

    it 'passes for an ActiveModel class' do
      expect(active_model_validating_confirmation_of(:attr)).
        to validate_confirmation_of(:attr)
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
end
