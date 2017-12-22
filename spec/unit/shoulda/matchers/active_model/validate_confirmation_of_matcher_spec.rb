require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateConfirmationOfMatcher, type: :model do
  include UnitTests::ConfirmationMatcherHelpers

  describe '#description' do
    it 'includes the name of the attribute which is being confirmed' do
      builder = builder_for_record_validating_confirmation
      matcher = described_class.new(builder.attribute_to_confirm)
      message = "validate confirmation of :#{builder.attribute_to_confirm}"
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

    it_supports(
      'ignoring_interference_by_writer',
      tests: {
        reject_if_qualified_but_changing_value_interferes: {
          model_name: 'Example',
          attribute_name: :password,
          changing_values_with: :next_value,
          expected_message: <<-MESSAGE.strip
Your test expecting Example to validate confirmation of :password didn't
pass.

The matcher ran the following subtests. Those indicated with ✘ failed
when they should have passed:

✔︎ Expected Example to be invalid with :password_confirmation set to
  ‹"some value"› and :password set to ‹"different value"› (which was
  read back as ‹"different valuf"›).
✘ Expected Example to be valid with :password_confirmation set to ‹"same
  value"› and :password set to ‹"same value"› (which was read back as
  ‹"same valuf"›). However, it produced these validation errors:

  * password_confirmation: ["doesn't match Password"]
✔︎ Expected Example to be valid with :password_confirmation set to ‹nil›
  and :password set to ‹"any value"› (which was read back as ‹"any
  valuf"›).

As indicated above, :password seems to be changing certain values as
they are set, and this could have something to do with why this matcher
is failing. If you've overridden the writer method for this attribute,
then you may need to change it to make this matcher pass. Otherwise, you
may need to do something else entirely.
          MESSAGE
        },
      },
      model_creator: :active_model
    )
  end

  context 'when the model does not have a confirmation attribute' do
    it 'raises an AttributeDoesNotExistError' do
      model = define_model(:example)

      assertion = lambda do
        expect(model.new).to validate_confirmation_of(:attribute_to_confirm)
      end

      message = <<-MESSAGE.rstrip
The matcher attempted to set :attribute_to_confirm_confirmation on the
Example to "some value", but that attribute does not exist.
      MESSAGE

      expect(&assertion).to raise_error(
        Shoulda::Matchers::ActiveModel::AllowValueMatcher::AttributeDoesNotExistError,
        message
      )
    end
  end

  context 'when the model does not have the attribute under test' do
    it 'raises an AttributeDoesNotExistError' do
      model = define_model(:example, attribute_to_confirm_confirmation: :string)

      assertion = lambda do
        expect(model.new).to validate_confirmation_of(:attribute_to_confirm)
      end

      message = <<-MESSAGE.rstrip
The matcher attempted to set :attribute_to_confirm on the Example to
"different value", but that attribute does not exist.
      MESSAGE

      expect(&assertion).to raise_error(
        Shoulda::Matchers::ActiveModel::AllowValueMatcher::AttributeDoesNotExistError,
        message
      )
    end
  end

  context 'when the model has all attributes, but does not have the validation' do
    it 'fails with an appropriate failure message' do
      model = define_model(:example, attribute_to_confirm: :string) do
        attr_accessor :attribute_to_confirm_confirmation
      end

      assertion = lambda do
        expect(model.new).to validate_confirmation_of(:attribute_to_confirm)
      end

      message = <<-MESSAGE
Your test expecting Example to validate confirmation of
:attribute_to_confirm didn't pass.

The matcher ran the following subtests. Those indicated with ✘ failed
when they should have passed:

✘ Expected Example to be invalid with :attribute_to_confirm_confirmation
  set to ‹"some value"› and :attribute_to_confirm set to ‹"different
  value"›. However, it was valid.
✔︎ Expected Example to be valid with :attribute_to_confirm_confirmation
  set to ‹"same value"› and :attribute_to_confirm set to ‹"same value"›.
✔︎ Expected Example to be valid with :attribute_to_confirm_confirmation
  set to ‹nil› and :attribute_to_confirm set to ‹"any value"›.
      MESSAGE

      expect(&assertion).to fail_with_message(message)
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

  def validation_matcher_scenario_args
    super.deep_merge(matcher_name: :validate_confirmation_of)
  end
end
