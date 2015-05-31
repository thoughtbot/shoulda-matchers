require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel::AllowValuesMatcher, type: :model do
  context 'when no values are provided' do
    it 'raises an error immediately' do
      expect { allow_values }.to raise_error(
        /You need to specify one or more values to test with/
      )
    end
  end

  context 'when no attribute is provided' do
    it 'raises an error when the matcher runs' do
      assertion = lambda do
        expect(any_object).to allow_values('foo', 'bar', 'baz')
      end

      expect(&assertion).to raise_error(
        /You need to specify an attribute to test against/
      )
    end

    def any_object
      Object.new
    end
  end

  context 'when the model has a validation on the attribute' do
    it 'matches positively when all of the given values are valid' do
      record = build_record_allowing_values(/\A[a-z]{3}\z/)
      expect(record).to allow_multiple('hat', 'kit', 'ban')
    end

    it 'does not match positively when some of the given values are invalid, producing an appropriate failure message' do
      record = build_record_allowing_values(/\A[a-z]{3}\z/)
      assertion = lambda do
        expect(record).to allow_multiple('hat', 'kite', 'ban')
      end
      message = <<-MESSAGE.strip_heredoc.chomp
        Did not expect errors when attr is set to "kite",
        got errors:
        * "is invalid" (attribute: attr, value: "kite")
      MESSAGE
      expect(&assertion).to fail_with_message(message)
    end

    it 'does not match positively when all of the given values are invalid, producing an appropriate failure message' do
      record = build_record_allowing_values(/\A[a-z]{3}\z/)
      assertion = lambda do
        expect(record).to allow_multiple('hate', 'kite', 'bane')
      end
      # message = <<-MESSAGE.strip_heredoc
        # Did not expect errors when attr is set to "hate", "kite", or "bane",
        # got errors:
        # * "is invalid" (attribute: attr, value: "hate")
        # * "is invalid" (attribute: attr, value: "kite")
        # * "is invalid" (attribute: attr, value: "bane")
      # MESSAGE
      message = <<-MESSAGE.strip_heredoc.chomp
        Did not expect errors when attr is set to "hate",
        got errors:
        * "is invalid" (attribute: attr, value: "hate")
      MESSAGE
      expect(&assertion).to fail_with_message(message)
    end

    context 'when the validation uses a custom message (a string)' do
      context 'when the matcher is qualified with the same message' do
        it 'matches positively when all of the given values are valid' do
          record = build_record_allowing_values(/\A[a-z]{3}\z/,
            message: 'custom message'
          )
          expect(record).
            to allow_multiple('hat', 'kit', 'ban').
            with_message('custom message')
        end

        it 'does not match positively when some of the given values are invalid, producing an appropriate failure message' do
          record = build_record_allowing_values(/\A[a-z]{3}\z/,
            message: 'custom message'
          )
          assertion = lambda do
            expect(record).
              to allow_multiple('hat', 'kite', 'ban').
              with_message('custom message')
          end
          message = <<-MESSAGE.strip_heredoc.chomp
            Did not expect errors to include "custom message" when attr is set to "kite",
            got errors:
            * "custom message" (attribute: attr, value: "kite")
          MESSAGE
          expect(&assertion).to fail_with_message(message)
        end

        it 'does not match positively when all of the given values are invalid, producing an appropriate failure message' do
          record = build_record_allowing_values(/\A[a-z]{3}\z/,
            message: 'custom message'
          )
          assertion = lambda do
            expect(record).
              to allow_multiple('hate', 'kite', 'bane').
              with_message('custom message')
          end
          # message = <<-MESSAGE.strip_heredoc
            # Did not expect errors when attr is set to "hate", "kite", or "bane",
            # got errors:
            # * "is invalid" (attribute: attr, value: "hate")
            # * "is invalid" (attribute: attr, value: "kite")
            # * "is invalid" (attribute: attr, value: "bane")
          # MESSAGE
          message = <<-MESSAGE.strip_heredoc.chomp
            Did not expect errors to include "custom message" when attr is set to "hate",
            got errors:
            * "custom message" (attribute: attr, value: "hate")
          MESSAGE
          expect(&assertion).to fail_with_message(message)
        end
      end

      context 'when the matcher is qualified with a regex matching the same message' do
        it 'matches positively when all of the given values are valid' do
          record = build_record_allowing_values(/\A[a-z]{3}\z/,
            message: 'custom message'
          )
          expect(record).
            to allow_multiple('hat', 'kit', 'ban').
            with_message(/message/)
        end

        it 'does not match positively when some of the given values are invalid, producing an appropriate failure message' do
          record = build_record_allowing_values(/\A[a-z]{3}\z/,
            message: 'custom message'
          )
          assertion = lambda do
            expect(record).
              to allow_multiple('hat', 'kite', 'ban').
              with_message(/message/)
          end
          message = <<-MESSAGE.strip_heredoc.chomp
            Did not expect errors to include /message/ when attr is set to "kite",
            got errors:
            * "custom message" (attribute: attr, value: "kite")
          MESSAGE
          expect(&assertion).to fail_with_message(message)
        end

        it 'does not match positively when all of the given values are invalid, producing an appropriate failure message' do
          record = build_record_allowing_values(/\A[a-z]{3}\z/,
            message: 'custom message'
          )
          assertion = lambda do
            expect(record).
              to allow_multiple('hate', 'kite', 'bane').
              with_message(/message/)
          end
          # message = <<-MESSAGE.strip_heredoc
            # Did not expect errors when attr is set to "hate", "kite", or "bane",
            # got errors:
            # * "is invalid" (attribute: attr, value: "hate")
            # * "is invalid" (attribute: attr, value: "kite")
            # * "is invalid" (attribute: attr, value: "bane")
          # MESSAGE
          message = <<-MESSAGE.strip_heredoc.chomp
            Did not expect errors to include /message/ when attr is set to "hate",
            got errors:
            * "custom message" (attribute: attr, value: "hate")
          MESSAGE
          expect(&assertion).to fail_with_message(message)
        end
      end

      context 'when the matcher is qualified with a different message' do
        it 'matches positively given a valid value' do
          # TODO: This should print a warning
          record = build_record_allowing_values(/abc/, message: 'custom message')
          expect(record).to allow_single('abcde').with_message('different message')
        end

        it 'does not match negatively given an invalid value, producing an appropriate failure message' do
          record = build_record_allowing_values(/abc/, message: 'custom message')
          assertion = lambda do
            expect(record).
              not_to allow_single('xyz').
              with_message('different message')
          end
          message = <<-MESSAGE.strip_heredoc.chomp
            Expected errors to include "different message" when attr is set to "xyz",
            got errors:
            * "custom message" (attribute: attr, value: "xyz")
          MESSAGE
          expect(&assertion).to fail_with_message(message)
        end
      end

      context 'when the matcher is qualified with no message' do
        it 'matches positively when all of the given values are valid' do
          # TODO: This should print a warning
          record = build_record_allowing_values(/\A[a-z]{3}\z/,
            message: 'custom message'
          )
          expect(record).to allow_multiple('hat', 'kit', 'ban')
        end

        it 'does not match positively when some of the given values are invalid, producing an appropriate failure message' do
          record = build_record_allowing_values(/\A[a-z]{3}\z/,
            message: 'custom message'
          )
          assertion = lambda do
            expect(record).to allow_multiple('hat', 'kite', 'ban')
          end
          message = <<-MESSAGE.strip_heredoc.chomp
            Did not expect errors when attr is set to "kite",
            got errors:
            * "custom message" (attribute: attr, value: "kite")
          MESSAGE
          expect(&assertion).to fail_with_message(message)
        end

        it 'does not match positively when all of the given values are invalid, producing an appropriate failure message' do
          record = build_record_allowing_values(/\A[a-z]{3}\z/,
            message: 'custom message'
          )
          assertion = lambda do
            expect(record).to allow_multiple('hate', 'kite', 'bane')
          end
          # message = <<-MESSAGE.strip_heredoc
            # Did not expect errors when attr is set to "hate", "kite", or "bane",
            # got errors:
            # * "is invalid" (attribute: attr, value: "hate")
            # * "is invalid" (attribute: attr, value: "kite")
            # * "is invalid" (attribute: attr, value: "bane")
          # MESSAGE
          message = <<-MESSAGE.strip_heredoc.chomp
            Did not expect errors when attr is set to "hate",
            got errors:
            * "custom message" (attribute: attr, value: "hate")
          MESSAGE
          expect(&assertion).to fail_with_message(message)
        end
      end
    end

    context 'when the validation uses a custom message (an i18n key)' do
      context 'when the matcher is qualified with the same message (an i18n key)' do
        it 'matches positively when all of the given values are valid' do
          record = build_record_allowing_values(/\A[a-z]{3}\z/, message: :taken)
          expect(record).
            to allow_multiple('hat', 'kit', 'ban').
            with_message(:taken)
        end

        it 'does not match positively when some of the given values are invalid, producing an appropriate failure message' do
          record = build_record_allowing_values(/\A[a-z]{3}\z/, message: :taken)
          assertion = lambda do
            expect(record).
              to allow_multiple('hat', 'kite', 'ban').
              with_message(:taken)
          end
          message = <<-MESSAGE.strip_heredoc.chomp
            Did not expect errors to include "has already been taken" when attr is set to "kite",
            got errors:
            * "has already been taken" (attribute: attr, value: "kite")
          MESSAGE
          expect(&assertion).to fail_with_message(message)
        end

        it 'does not match positively when all of the given values are invalid, producing an appropriate failure message' do
          record = build_record_allowing_values(/\A[a-z]{3}\z/, message: :taken)
          assertion = lambda do
            expect(record).
              to allow_multiple('hate', 'kite', 'bane').
              with_message(:taken)
          end
          # message = <<-MESSAGE.strip_heredoc
            # Did not expect errors when attr is set to "hate", "kite", or "bane",
            # got errors:
            # * "is invalid" (attribute: attr, value: "hate")
            # * "is invalid" (attribute: attr, value: "kite")
            # * "is invalid" (attribute: attr, value: "bane")
          # MESSAGE
          message = <<-MESSAGE.strip_heredoc.chomp
            Did not expect errors to include "has already been taken" when attr is set to "hate",
            got errors:
            * "has already been taken" (attribute: attr, value: "hate")
          MESSAGE
          expect(&assertion).to fail_with_message(message)
        end
      end

      context 'when the matcher is qualified with the same message (a string)' do
        it 'matches positively when all of the given values are valid' do
          record = build_record_allowing_values(/\A[a-z]{3}\z/, message: :taken)
          expect(record).
            to allow_multiple('hat', 'kit', 'ban').
            with_message('has already been taken')
        end

        it 'does not match positively when some of the given values are invalid, producing an appropriate failure message' do
          record = build_record_allowing_values(/\A[a-z]{3}\z/, message: :taken)
          assertion = lambda do
            expect(record).
              to allow_multiple('hat', 'kite', 'ban').
              with_message('has already been taken')
          end
          message = <<-MESSAGE.strip_heredoc.chomp
            Did not expect errors to include "has already been taken" when attr is set to "kite",
            got errors:
            * "has already been taken" (attribute: attr, value: "kite")
          MESSAGE
          expect(&assertion).to fail_with_message(message)
        end

        it 'does not match positively when all of the given values are invalid, producing an appropriate failure message' do
          record = build_record_allowing_values(/\A[a-z]{3}\z/, message: :taken)
          assertion = lambda do
            expect(record).
              to allow_multiple('hate', 'kite', 'bane').
              with_message('has already been taken')
          end
          # message = <<-MESSAGE.strip_heredoc
            # Did not expect errors when attr is set to "hate", "kite", or "bane",
            # got errors:
            # * "is invalid" (attribute: attr, value: "hate")
            # * "is invalid" (attribute: attr, value: "kite")
            # * "is invalid" (attribute: attr, value: "bane")
          # MESSAGE
          message = <<-MESSAGE.strip_heredoc.chomp
            Did not expect errors to include "has already been taken" when attr is set to "hate",
            got errors:
            * "has already been taken" (attribute: attr, value: "hate")
          MESSAGE
          expect(&assertion).to fail_with_message(message)
        end
      end

      context 'when the matcher is qualified with a regex matching the same message' do
        it 'matches positively when all of the given values are valid' do
          record = build_record_allowing_values(/\A[a-z]{3}\z/,
            message: :taken
          )
          expect(record).
            to allow_multiple('hat', 'kit', 'ban').
            with_message(/taken/)
        end

        it 'does not match positively when some of the given values are invalid, producing an appropriate failure message' do
          record = build_record_allowing_values(/\A[a-z]{3}\z/,
            message: :taken
          )
          assertion = lambda do
            expect(record).
              to allow_multiple('hat', 'kite', 'ban').
              with_message(/taken/)
          end
          message = <<-MESSAGE.strip_heredoc.chomp
            Did not expect errors to include /taken/ when attr is set to "kite",
            got errors:
            * "has already been taken" (attribute: attr, value: "kite")
          MESSAGE
          expect(&assertion).to fail_with_message(message)
        end

        it 'does not match positively when all of the given values are invalid, producing an appropriate failure message' do
          record = build_record_allowing_values(/\A[a-z]{3}\z/,
            message: :taken
          )
          assertion = lambda do
            expect(record).
              to allow_multiple('hate', 'kite', 'bane').
              with_message(/taken/)
          end
          # message = <<-MESSAGE.strip_heredoc
            # Did not expect errors when attr is set to "hate", "kite", or "bane",
            # got errors:
            # * "is invalid" (attribute: attr, value: "hate")
            # * "is invalid" (attribute: attr, value: "kite")
            # * "is invalid" (attribute: attr, value: "bane")
          # MESSAGE
          message = <<-MESSAGE.strip_heredoc.chomp
            Did not expect errors to include /taken/ when attr is set to "hate",
            got errors:
            * "has already been taken" (attribute: attr, value: "hate")
          MESSAGE
          expect(&assertion).to fail_with_message(message)
        end
      end

      context 'when the matcher is qualified with a different message (i18n key or otherwise)' do
        it 'matches positively given a valid value' do
          # TODO: This should print a warning
          record = build_record_allowing_values(/abc/, message: :taken)
          expect(record).to allow_single('abcde').with_message('different message')
        end

        it 'does not match negatively given an invalid value, producing an appropriate failure message' do
          record = build_record_allowing_values(/abc/, message: :taken)
          assertion = lambda do
            expect(record).
              not_to allow_single('xyz').
              with_message('different message')
          end
          message = <<-MESSAGE.strip_heredoc.chomp
            Expected errors to include "different message" when attr is set to "xyz",
            got errors:
            * "has already been taken" (attribute: attr, value: "xyz")
          MESSAGE
          expect(&assertion).to fail_with_message(message)
        end
      end

      context 'when the matcher is qualified with no message' do
        it 'matches positively when all of the given values are valid' do
          # TODO: This should print a warning
          record = build_record_allowing_values(/\A[a-z]{3}\z/,
            message: :taken
          )
          expect(record).to allow_multiple('hat', 'kit', 'ban')
        end

        it 'does not match positively when some of the given values are invalid, producing an appropriate failure message' do
          record = build_record_allowing_values(/\A[a-z]{3}\z/,
            message: :taken
          )
          assertion = lambda do
            expect(record).to allow_multiple('hat', 'kite', 'ban')
          end
          message = <<-MESSAGE.strip_heredoc.chomp
            Did not expect errors when attr is set to "kite",
            got errors:
            * "has already been taken" (attribute: attr, value: "kite")
          MESSAGE
          expect(&assertion).to fail_with_message(message)
        end

        it 'does not match positively when all of the given values are invalid, producing an appropriate failure message' do
          record = build_record_allowing_values(/\A[a-z]{3}\z/,
            message: :taken
          )
          assertion = lambda do
            expect(record).to allow_multiple('hate', 'kite', 'bane')
          end
          # message = <<-MESSAGE.strip_heredoc
            # Did not expect errors when attr is set to "hate", "kite", or "bane",
            # got errors:
            # * "is invalid" (attribute: attr, value: "hate")
            # * "is invalid" (attribute: attr, value: "kite")
            # * "is invalid" (attribute: attr, value: "bane")
          # MESSAGE
          message = <<-MESSAGE.strip_heredoc.chomp
            Did not expect errors when attr is set to "hate",
            got errors:
            * "has already been taken" (attribute: attr, value: "hate")
          MESSAGE
          expect(&assertion).to fail_with_message(message)
        end
      end
    end

    context 'when the validation uses a custom message (an i18n key + interpolation values)' do
      context 'when the matcher is qualified with the same message + same values' do
        before do
          UnitTests::I18nFaker.stub_validation_error(
            model_name: :example,
            attribute_name: :attr,
            message: :custom_message,
            value: 'custom message'
          )
        end

        it 'matches positively when all of the given values are valid' do
          record = build_record_allowing_values(/\A[a-z]{3}\z/,
            attribute_name: :attr,
            model_name: :example,
            message: :custom_message
          )
          expect(record).
            to allow_multiple('hat', 'kit', 'ban').
            with_message(:custom_message)
        end

        it 'does not match positively when some of the given values are invalid, producing an appropriate failure message' do
          record = build_record_allowing_values(/\A[a-z]{3}\z/,
            attribute_name: :attr,
            model_name: :example,
            message: :custom_message
          )
          assertion = lambda do
            expect(record).
              to allow_multiple('hat', 'kite', 'ban').
              with_message(:custom_message)
          end
          message = <<-MESSAGE.strip_heredoc.chomp
            Did not expect errors to include "custom message" when attr is set to "kite",
            got errors:
            * "custom message" (attribute: attr, value: "kite")
          MESSAGE
          expect(&assertion).to fail_with_message(message)
        end

        it 'does not match positively when all of the given values are invalid, producing an appropriate failure message' do
          record = build_record_allowing_values(/\A[a-z]{3}\z/,
            attribute_name: :attr,
            model_name: :example,
            message: :custom_message
          )
          assertion = lambda do
            expect(record).
              to allow_multiple('hate', 'kite', 'bane').
              with_message(:custom_message)
          end
          # message = <<-MESSAGE.strip_heredoc
            # Did not expect errors when attr is set to "hate", "kite", or "bane",
            # got errors:
            # * "is invalid" (attribute: attr, value: "hate")
            # * "is invalid" (attribute: attr, value: "kite")
            # * "is invalid" (attribute: attr, value: "bane")
          # MESSAGE
          message = <<-MESSAGE.strip_heredoc.chomp
            Did not expect errors to include "custom message" when attr is set to "hate",
            got errors:
            * "custom message" (attribute: attr, value: "hate")
          MESSAGE
          expect(&assertion).to fail_with_message(message)
        end
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

=begin
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
=end
  end

=begin
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
=end

  def build_model_allowing_values(regexp, options = {})
    model_name = options.delete(:model_name) { 'Example' }
    options = { with: regexp }.merge(options)
    attribute = options.fetch(:attribute_being_validated) do
      attribute_being_validated
    end
    define_model model_name, attribute => :string do |model|
      model.validates_format_of(attribute, options)
    end
  end

  def build_record_allowing_values(regexp, options = {})
    build_model_allowing_values(regexp, options).new
  end

  def allow_single(value)
    allow_value(value).for(attribute_being_validated)
  end

  def allow_multiple(*values)
    allow_values(*values).for(attribute_being_validated)
  end

  def attribute_being_validated
    :attr
  end
end
