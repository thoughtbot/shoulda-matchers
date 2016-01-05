require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateAcceptanceOfMatcher, type: :model do
  context 'a model with an acceptance validation' do
    it 'accepts when the attributes match' do
      expect(record_validating_acceptance).to matcher
    end

    it 'does not overwrite the default message with nil' do
      expect(record_validating_acceptance).to matcher.with_message(nil)
    end

    it_supports(
      'ignoring_interference_by_writer',
      tests: {
        accept_if_qualified_but_changing_value_does_not_interfere: {
          changing_values_with: :never_falsy,
        },
        reject_if_qualified_but_changing_value_interferes: {
          model_name: 'Example',
          attribute_name: :attr,
          changing_values_with: :always_nil,
          expected_message: <<-MESSAGE.strip
Example did not properly validate that :attr has been set to "1".
  After setting :attr to ‹false› -- which was read back as ‹nil› -- the
  matcher expected the Example to be invalid, but it was valid instead.

  As indicated in the message above, :attr seems to be changing certain
  values as they are set, and this could have something to do with why
  this test is failing. If you've overridden the writer method for this
  attribute, then you may need to change it to make this test pass, or
  do something else entirely.
          MESSAGE
        },
      },
      model_creator: :active_model
    )
  end

  context 'a model without an acceptance validation' do
    it 'rejects' do
      expect(record_validating_nothing).not_to matcher
    end
  end

  context 'an attribute which must be accepted with a custom message' do
    it 'accepts when the message matches' do
      expect(record_validating_acceptance(message: 'custom')).
        to matcher.with_message(/custom/)
    end

    it 'rejects when the message does not match' do
      expect(record_validating_acceptance(message: 'custom')).
        not_to matcher.with_message(/wrong/)
    end
  end

  def matcher
    validate_acceptance_of(:attr)
  end

  def model_validating_nothing(options = {}, &block)
    attribute_name = options.fetch(:attribute_name, :attr)
    define_active_model_class(:example, accessors: [attribute_name], &block)
  end

  def record_validating_nothing
    model_validating_nothing.new
  end

  def model_validating_acceptance(options = {})
    attribute_name = options.fetch(:attribute_name, :attr)

    model_validating_nothing(attribute_name: attribute_name) do
      validates_acceptance_of attribute_name, options
    end
  end

  alias_method :define_model_validating_acceptance, :model_validating_acceptance

  def record_validating_acceptance(options = {})
    model_validating_acceptance(options).new
  end

  alias_method :build_record_validating_acceptance,
    :record_validating_acceptance

  def validation_matcher_scenario_args
    { matcher_name: :validate_acceptance_of }
  end
end
