require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel, type: :model do
  describe '#allow_values' do
    it 'is aliased to #allow_value' do
      expect(method(:allow_values)).to eq(method(:allow_value))
    end
  end
end

describe Shoulda::Matchers::ActiveModel::AllowValueMatcher, type: :model do
  context "#description" do
    it 'describes itself with multiple values' do
      matcher = allow_value('foo', 'bar').for(:baz)

      expect(matcher.description).to eq 'allow baz to be set to any of ["foo", "bar"]'
    end

    it 'describes itself with a single value' do
      matcher = allow_value('foo').for(:baz)

      expect(matcher.description).to eq 'allow baz to be set to "foo"'
    end

    if active_model_3_2?
      it 'describes itself with a strict validation' do
        strict_matcher = allow_value('xyz').for(:attr).strict

        expect(strict_matcher.description).
          to eq %q(doesn't raise when attr is set to "xyz")
      end
    end
  end

  describe '#_after_setting_value' do
    it 'sets a block which is yielded after each value is set on the attribute' do
      attribute = :attr
      record = define_model(:example, attribute => :string).new
      matcher = described_class.new('a', 'b', 'c').for(attribute)
      call_count = 0

      matcher._after_setting_value { call_count += 1 }
      matcher.matches?(record)

      expect(call_count).to eq 3
    end
  end

  context 'an attribute with a validation' do
    it 'allows a good value' do
      expect(validating_format(with: /abc/)).to allow_value('abcde').for(:attr)
    end

    it 'rejects a bad value' do
      expect(validating_format(with: /abc/)).not_to allow_value('xyz').for(:attr)
    end

    it 'allows several good values' do
      expect(validating_format(with: /abc/)).
        to allow_value('abcde', 'deabc').for(:attr)
    end

    it 'rejects several bad values' do
      expect(validating_format(with: /abc/)).
        not_to allow_value('xyz', 'zyx', nil, []).
        for(:attr).
        ignoring_interference_by_writer
    end
  end

  context 'an attribute with a validation and a custom message' do
    it 'allows a good value' do
      expect(validating_format(with: /abc/, message: 'bad value')).
        to allow_value('abcde').for(:attr).with_message(/bad/)
    end

    it 'rejects a bad value' do
      expect(validating_format(with: /abc/, message: 'bad value')).
        not_to allow_value('xyz').for(:attr).with_message(/bad/)
    end

    it 'allows interpolation values for the message to be provided' do
      options = {
        attribute_name: :attr,
        attribute_type: :string
      }

      record = record_with_custom_validation(options) do
        if self.attr == 'xyz'
          self.errors.add :attr, :greater_than, count: 2
        end
      end

      expect(record).
        not_to allow_value('xyz').
        for(:attr).
        with_message(:greater_than, values: { count: 2 })
    end
  end

  context 'when the attribute being validated is different than the attribute that receives the validation error' do
    include UnitTests::AllowValueMatcherHelpers

    context 'when the validation error message was provided directly' do
      it 'passes given a valid value' do
        builder = builder_for_record_with_different_error_attribute
        expect(builder.record).
          to allow_value(builder.valid_value).
          for(builder.attribute_to_validate).
          with_message(builder.message,
            against: builder.attribute_that_receives_error
          )
      end

      it 'fails given an invalid value' do
        builder = builder_for_record_with_different_error_attribute
        invalid_value = "#{builder.valid_value} (invalid)"
        expect(builder.record).
          not_to allow_value(invalid_value).
          for(builder.attribute_to_validate).
          with_message(builder.message,
            against: builder.attribute_that_receives_error
          )
      end
    end

    context 'when the validation error message was provided via i18n' do
      it 'passes given a valid value' do
        builder = builder_for_record_with_different_error_attribute_using_i18n
        expect(builder.record).
          to allow_value(builder.valid_value).
          for(builder.attribute_to_validate).
          with_message(builder.validation_message_key,
            against: builder.attribute_that_receives_error
          )
      end

      it 'fails given an invalid value' do
        builder = builder_for_record_with_different_error_attribute_using_i18n
        invalid_value = "#{builder.valid_value} (invalid)"
        expect(builder.record).
          not_to allow_value(invalid_value).
          for(builder.attribute_to_validate).
          with_message(builder.validation_message_key,
            against: builder.attribute_that_receives_error
          )
      end
    end
  end

  context "an attribute with a context-dependent validation" do
    context "without the validation context" do
      it "allows a bad value" do
        expect(validating_format(with: /abc/, on: :customisable)).to allow_value("xyz").for(:attr)
      end
    end

    context "with the validation context" do
      it "allows a good value" do
        expect(validating_format(with: /abc/, on: :customisable)).to allow_value("abcde").for(:attr).on(:customisable)
      end

      it "rejects a bad value" do
        expect(validating_format(with: /abc/, on: :customisable)).not_to allow_value("xyz").for(:attr).on(:customisable)
      end
    end
  end

  context 'an attribute with several validations' do
    let(:model) do
      define_model :example, attr: :string do
        validates_presence_of     :attr
        validates_length_of       :attr, within: 1..5
        validates_numericality_of :attr, greater_than_or_equal_to: 1,
          less_than_or_equal_to: 50000
      end.new
    end

    bad_values = [nil, '', 'abc', '0', '50001', '123456', []]

    it 'matches given a good value' do
      expect(model).to allow_value('12345').for(:attr)
    end

    it 'does not match given a bad value' do
      bad_values.each do |bad_value|
        expect(model).
          not_to allow_value(bad_value).
          for(:attr).
          ignoring_interference_by_writer
      end
    end

    it 'does not match given multiple bad values' do
      expect(model).
        not_to allow_value(*bad_values).
        for(:attr).
        ignoring_interference_by_writer
    end

    it "does not match given good values along with bad values" do
      message = %{Expected errors when attr is set to "12345",\ngot no errors}

      expect {
        expect(model).not_to allow_value('12345', *bad_values).for(:attr)
      }.to fail_with_message(message)
    end
  end

  context 'with a single value' do
    it 'allows you to call description before calling matches?' do
      model = define_model(:example, attr: :string).new
      matcher = described_class.new('foo').for(:attr)
      matcher.description

      expect { matcher.matches?(model) }.not_to raise_error
    end
  end

  context 'with no values' do
    it 'raises an error' do
      expect { allow_value.for(:baz) }.
        to raise_error(ArgumentError, /at least one argument/)
    end
  end

  if active_model_3_2?
    context 'an attribute with a strict format validation' do
      it 'strictly rejects a bad value' do
        expect(validating_format(with: /abc/, strict: true)).
          not_to allow_value('xyz').for(:attr).strict
      end

      it 'strictly allows a bad value with a different message' do
        expect(validating_format(with: /abc/, strict: true)).
          to allow_value('xyz').for(:attr).with_message(/abc/).strict
      end

      it 'provides a useful negative failure message' do
        matcher = allow_value('xyz').for(:attr).strict.with_message(/abc/)

        matcher.matches?(validating_format(with: /abc/, strict: true))

        expect(matcher.failure_message_when_negated).to eq(
          %{Expected exception to include /abc/ when attr is set to "xyz",\n} +
          %{got: "Attr is invalid"}
        )
      end
    end
  end

  context 'when the attribute interferes with attempts to be set' do
    context 'when the matcher has not been qualified with #ignoring_interference_by_writer' do
      context 'when the attribute cannot be changed from nil to non-nil' do
        it 'raises a CouldNotSetAttributeError' do
          model = define_active_model_class 'Example' do
            attr_reader :name

            def name=(_value)
              nil
            end
          end

          assertion = -> {
            expect(model.new).to allow_value('anything').for(:name)
          }

          expect(&assertion).to raise_error(
            described_class::CouldNotSetAttributeError
          )
        end
      end

      context 'when the attribute cannot be changed from non-nil to nil' do
        it 'raises a CouldNotSetAttribute error' do
          model = define_active_model_class 'Example' do
            attr_reader :name

            def name=(value)
              @name = value unless value.nil?
            end
          end

          record = model.new(name: 'some name')

          assertion = -> {
            expect(record).to allow_value(nil).for(:name)
          }

          expect(&assertion).to raise_error(
            described_class::CouldNotSetAttributeError
          )
        end
      end

      context 'when the attribute cannot be changed from a non-nil value to another non-nil value' do
        it 'raises a CouldNotSetAttribute error' do
          model = define_active_model_class 'Example' do
            attr_reader :name

            def name=(_value)
              @name = 'constant name'
            end
          end

          record = model.new(name: 'some name')

          assertion = -> {
            expect(record).to allow_value('another name').for(:name)
          }

          expect(&assertion).to raise_error(
            described_class::CouldNotSetAttributeError
          )
        end
      end
    end

    context 'when the matcher has been qualified with #ignoring_interference_by_writer' do
      context 'when the attribute cannot be changed from nil to non-nil' do
        it 'does not raise an error at all' do
          model = define_active_model_class 'Example' do
            attr_reader :name

            def name=(_value)
              nil
            end
          end

          assertion = lambda do
            expect(model.new).
              to allow_value('anything').
              for(:name).
              ignoring_interference_by_writer
          end

          expect(&assertion).not_to raise_error
        end
      end

      context 'when the attribute cannot be changed from non-nil to nil' do
        it 'does not raise an error at all' do
          model = define_active_model_class 'Example' do
            attr_reader :name

            def name=(value)
              @name = value unless value.nil?
            end
          end

          record = model.new(name: 'some name')

          assertion = lambda do
            expect(record).
              to allow_value(nil).
              for(:name).
              ignoring_interference_by_writer
          end

          expect(&assertion).not_to raise_error
        end
      end

      context 'when the attribute cannot be changed from a non-nil value to another non-nil value' do
        it 'does not raise an error at all' do
          model = define_active_model_class 'Example' do
            attr_reader :name

            def name=(_value)
              @name = 'constant name'
            end
          end

          record = model.new(name: 'some name')

          assertion = lambda do
            expect(record).
              to allow_value('another name').
              for(:name).
              ignoring_interference_by_writer
          end

          expect(&assertion).not_to raise_error
        end
      end
    end
  end
end
