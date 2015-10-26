require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateAcceptanceOfMatcher, type: :model do
  context 'a model with an acceptance validation' do
    it 'accepts when the attributes match' do
      expect(record_validating_acceptance).to matcher
    end

    it 'does not overwrite the default message with nil' do
      expect(record_validating_acceptance).to matcher.with_message(nil)
    end
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

  context 'when the writer method for the attribute changes incoming values' do
    context 'and the matcher knows nothing of this' do
      it 'raises a CouldNotSetAttributeError' do
        model = define_model_validating_acceptance(
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

        assertion = lambda do
          expect(model.new).to validate_acceptance_of(:terms_of_service)
        end

        expect(&assertion).to raise_error(
          Shoulda::Matchers::ActiveModel::AllowValueMatcher::CouldNotSetAttributeError
        )
      end
    end

    context 'and the matcher knows how given values get changed' do
      it 'accepts (and not raise an error)' do
        model = define_model_validating_acceptance(
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
end
