require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel::AllowValuesMatcher, type: :model do
  shared_examples 'basic tests' do
    it 'matches when the given values are valid' do
      record = build_record_allowing_values(/[a-z]{3}/)
      matcher = wrap_allow_values(allow('hat', 'kit', 'ban'))
      expect(record).to matcher
    end

    it 'does not match when some of the given values are invalid, producing an appropriate failure message' do
      record = build_record_allowing_values(/[a-z]{3}/)
      matcher = wrap_allow_values(allow('hat', 'kite', 'ban'))
      assertion = -> { expect(record).not_to matcher }
      expect(&assertion).to fail_with_message(<<-MESSAGE)
        Did not expect errors when attr is set to "kite",
        got errors:
        * "is invalid" (attribute: attr, value: "kite")
      MESSAGE
    end

    it 'does not match when all of the given values are invalid, producing an appropriate failure message' do
      record = build_record_allowing_values(/[a-z]{3}/)
      matcher = wrap_allow_values(allow('hate', 'kite', 'bane'))
      assertion = -> { expect(record).not_to matcher }
      expect(&assertion).to fail_with_message(<<-MESSAGE)
        Did not expect errors when attr is set to "hate", "kite", or "bane",
        got errors:
        * "is invalid" (attribute: attr, value: "hate")
        * "is invalid" (attribute: attr, value: "kite")
        * "is invalid" (attribute: attr, value: "bane")
      MESSAGE
    end

    def wrap_allow_values(matcher)
      matcher
    end
  end

  context 'when no values are provided' do
    it 'raises an ArgumentError immediately' do
      expect { allow_values }.to raise_error(
        ArgumentError,
        '#allow_values requires values to test with'
      )
    end
  end

  context 'when no attribute is provided' do
    it 'raises an ArgumentError when the matcher runs' do
      assertion = lambda do
        expect(any_object).to allow_values('foo', 'bar', 'baz')
      end

      expect(&assertion).to raise_error(
        ArgumentError,
        '#allow_values requires an attribute to test against'
      )
    end

    def any_object
      Object.new
    end
  end

  context 'when the model has a validation on the attribute' do
    include_examples 'basic tests'

    context 'when the validation uses a custom message (a string)' do
      context 'when the matcher is qualified with the same message' do
        include_examples 'basic tests'
      end

      context 'when the matcher is qualified with a different message' do
        it 'does not match, producing an appropriate failure message'
      end

      context 'when the matcher is qualified with no message' do
        it 'does not match, producing an appropriate failure message'
      end
    end

    context 'when the validation uses a custom message (an i18n key)' do
      context 'when the matcher is qualified with the same message' do
        include_examples 'basic tests'
      end

      context 'when the matcher is qualified with a different message' do
        it 'does not match, producing an appropriate failure message'
      end

      context 'when the matcher is qualified with no message' do
        it 'does not match, producing an appropriate failure message'
      end
    end

    context 'when the validation uses a custom message (an i18n key + interpolation values)' do
      context 'when the matcher is qualified with the same message + same values' do
        include_examples 'basic tests'
      end

      context 'when the matcher is qualified with the same message + different values' do
        it 'does not match, producing an appropriate failure message'
      end

      context 'when the matcher is qualified with a different message' do
        it 'does not match, producing an appropriate failure message'
      end

      context 'when the matcher is qualified with no message' do
        it 'does not match, producing an appropriate failure message'
      end
    end

    context 'when the validation uses a custom message, but on an attribute different from the one being validated' do
      context 'when the matcher is qualified with the same custom attribute' do
        include_examples 'basic tests'
      end

      context 'when the matcher is qualified with a different custom attribute' do
        it 'does not match, producing an appropriate failure message'
      end

      context 'when the matcher is qualified with no custom attribute' do
        it 'does not match, producing an appropriate failure message'
      end
    end

    context 'when the validation does not use a custom message' do
      context 'when the matcher is qualified with a message (string)' do
        it 'does not match, producing an appropriate failure message'
      end

      context 'when the matcher is qualified with a message (i18n key)' do
        it 'does not match, producing an appropriate failure message'
      end

      context 'when the matcher is qualified with a message on a custom attribute' do
        it 'does not match, producing an appropriate failure message'
      end
    end

    context 'when the validation is guarded by a context' do
      context 'when the matcher is qualified with the same context' do
        it 'matches'
      end

      context 'when the matcher is qualified with a different context' do
        it 'does not match, producing an appropriate failure message'
      end

      context 'when the matcher is not qualified with a context' do
        it 'does not match, producing an appropriate failure message'
      end
    end

    context 'when the validation is not guarded by a context' do
      context 'when the matcher is qualified with a context' do
        it 'does not match, producing an appropriate failure message'
      end
    end

    context 'when the attribute is being validated strictly' do
      context 'when the matcher is qualified with #strict' do
      end

      context 'when the matcher is not qualified with #strict' do
        it 'does not match, producing an appropriate failure message'
      end
    end

    context 'when the attribute is not being validated strictly' do
      context 'when the matcher is qualified with #strict' do
        it 'does not match, producing an appropriate failure message'
      end
    end
  end

  context 'when the model has several validations on the attribute' do
    include_examples 'basic tests'
  end

  context 'when the model has no validations' do
    it 'does not match, producing an appropriate failure message'
  end

  describe '#description' do
    it 'returns an appropriate default description'

    context 'qualified with #on' do
      it 'includes the context in the description'
    end

    context 'qualified with #strict' do
      it 'includes the fact that it is checking strict validation'
    end

    context 'qualified with #with_message' do
      it 'includes the fact it is using a custom message'
    end
  end

  def build_model_allowing_values(regexp)
    define_model 'Example', attribute_being_validated => :string do |model|
      model.validates_format_of(attribute_being_validated, with: regexp)
    end
  end

  def build_record_allowing_values(regexp)
    build_model_allowing_values(regexp).new
  end

  def allow(*values)
    allow_values(*values).for(attribute_being_validated)
  end

  def attribute_being_validated
    :attr
  end
end
