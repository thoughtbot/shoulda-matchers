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
    it 'describes itself with two values' do
      matcher = allow_value('foo', 'bar').for(:baz)

      expect(matcher.description).to eq(
        'allow :baz to be ‹"foo"› or ‹"bar"›'
      )
    end

    it 'describes itself with more than two values' do
      matcher = allow_value('foo', 'bar', 'qux').for(:baz)

      expect(matcher.description).to eq(
        'allow :baz to be ‹"foo"›, ‹"bar"›, or ‹"qux"›'
      )
    end

    it 'describes itself with a single value' do
      matcher = allow_value('foo').for(:baz)

      expect(matcher.description).to eq 'allow :baz to be ‹"foo"›'
    end

    if active_model_3_2?
      it 'describes itself with a strict validation' do
        strict_matcher = allow_value('xyz').for(:attr).strict

        expect(strict_matcher.description).to eq(
          'allow :attr to be ‹"xyz"›, raising a validation exception on failure'
        )
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
    context 'given one good value' do
      context 'when used in the positive' do
        it 'accepts' do
          expect(validating_format(with: /abc/)).
            to allow_value('abcde').for(:attr)
        end
      end

      context 'when used in the negative' do
        it 'rejects with an appropriate failure message' do
          assertion = lambda do
            expect(validating_format(with: /abc/)).
              not_to allow_value('abcde').for(:attr)
          end

          message = <<-MESSAGE
After setting :attr to ‹"abcde"›, the matcher expected the Example to be
invalid, but it was valid instead.
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end
    end

    context 'given several good values' do
      context 'when used in the positive' do
        it 'accepts' do
          expect(validating_format(with: /abc/)).
            to allow_value('abcde', 'deabc').for(:attr)
        end
      end

      context 'when used in the negative' do
        it 'rejects with an appropriate failure message' do
          assertion = lambda do
            expect(validating_format(with: /abc/)).
              not_to allow_value('abcde', 'deabc').for(:attr)
          end

          message = <<-MESSAGE
After setting :attr to ‹"abcde"›, the matcher expected the Example to be
invalid, but it was valid instead.
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end
    end

    context 'given one bad value' do
      context 'when used in the positive' do
        it 'rejects with an appropriate failure message' do
          assertion = lambda do
            expect(validating_format(with: /abc/)).
              to allow_value('xyz').for(:attr)
          end

          message = <<-MESSAGE
After setting :attr to ‹"xyz"›, the matcher expected the Example to be
valid, but it was invalid instead, producing these validation errors:

* attr: ["is invalid"]
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end

      context 'when used in the negative' do
        it 'accepts' do
          expect(validating_format(with: /abc/)).
            not_to allow_value('xyz').for(:attr)
        end
      end
    end

    context 'given several bad values' do
      context 'when used in the positive' do
        it 'rejects with an appropriate failure message' do
          assertion = lambda do
            expect(validating_format(with: /abc/)).
              to allow_value('xyz', 'zyx', nil, []).
              for(:attr).
              ignoring_interference_by_writer
          end

          message = <<-MESSAGE
After setting :attr to ‹"xyz"›, the matcher expected the Example to be
valid, but it was invalid instead, producing these validation errors:

* attr: ["is invalid"]
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end

      context 'when used in the negative' do
        it 'accepts' do
          expect(validating_format(with: /abc/)).
            not_to allow_value('xyz', 'zyx', nil, []).
            for(:attr).
            ignoring_interference_by_writer
        end
      end
    end

    context 'given good values along with bad values' do
      context 'when used in the positive' do
        it 'rejects with an appropriate failure message' do
          assertion = lambda do
            expect(validating_format(with: /abc/)).
              to allow_value('abc', 'xyz').
              for(:attr).
              ignoring_interference_by_writer
          end

          message = <<-MESSAGE
After setting :attr to ‹"xyz"›, the matcher expected the Example to be
valid, but it was invalid instead, producing these validation errors:

* attr: ["is invalid"]
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end

      context 'when used in the negative' do
        it 'rejects with an appropriate failure message' do
          assertion = lambda do
            expect(validating_format(with: /abc/)).
              not_to allow_value('abc', 'xyz').
              for(:attr).
              ignoring_interference_by_writer
          end

          message = <<-MESSAGE
After setting :attr to ‹"abc"›, the matcher expected the Example to be
invalid, but it was valid instead.
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end
    end

    context 'given bad values along with good values' do
      context 'when used in the positive' do
        it 'rejects with an appropriate failure message' do
          assertion = lambda do
            expect(validating_format(with: /abc/)).
              to allow_value('xyz', 'abc').
              for(:attr).
              ignoring_interference_by_writer
          end

          message = <<-MESSAGE
After setting :attr to ‹"xyz"›, the matcher expected the Example to be
valid, but it was invalid instead, producing these validation errors:

* attr: ["is invalid"]
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end

      context 'when used in the negative' do
        it 'rejects with an appropriate failure message' do
          assertion = lambda do
            expect(validating_format(with: /abc/)).
              not_to allow_value('xyz', 'abc').
              for(:attr).
              ignoring_interference_by_writer
          end

          message = <<-MESSAGE
After setting :attr to ‹"abc"›, the matcher expected the Example to be
invalid, but it was valid instead.
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end
    end
  end

  context 'an attribute with a validation and a custom message' do
    it 'allows a good value' do
      expect(validating_format(with: /abc/, message: 'bad value')).
        to allow_value('abcde').for(:attr).with_message(/bad/)
    end

    it 'rejects a bad value with an appropriate failure message' do
      message = <<-MESSAGE
After setting :attr to ‹"xyz"›, the matcher expected the Example to be
valid, but it was invalid instead, producing these validation errors:

* attr: ["bad value"]
      MESSAGE

      assertion = lambda do
        expect(validating_format(with: /abc/, message: 'bad value')).
          to allow_value('xyz').for(:attr).with_message(/bad/)
      end

      expect(&assertion).to fail_with_message(message)
    end

    context 'when the custom messages do not match' do
      it 'rejects with an appropriate failure message' do
        message = <<-MESSAGE
After setting :attr to ‹"xyz"›, the matcher expected the Example to be
invalid and to produce a validation error matching ‹/different/› on
:attr. The record was indeed invalid, but it produced these validation
errors instead:

* attr: ["bad value"]
        MESSAGE

        assertion = lambda do
          expect(validating_format(with: /abc/, message: 'bad value')).
            not_to allow_value('xyz').for(:attr).with_message(/different/)
        end

        expect(&assertion).to fail_with_message(message)
      end
    end

    context 'when interpolation values are provided along with a custom message' do
      context 'when the messages match' do
        it 'accepts' do
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

      context 'when the messages do not match' do
        it 'rejects with an appropriate failure message' do
          options = {
            attribute_name: :attr,
            attribute_type: :string
          }

          record = record_with_custom_validation(options) do
            if self.attr == 'xyz'
              self.errors.add :attr, "some other error"
            end
          end

          assertion = lambda do
            expect(record).
              not_to allow_value('xyz').
              for(:attr).
              with_message(:greater_than, values: { count: 2 })
          end

          message = <<-MESSAGE
After setting :attr to ‹"xyz"›, the matcher expected the Example to be
invalid and to produce the validation error "must be greater than 2" on
:attr. The record was indeed invalid, but it produced these validation
errors instead:

* attr: ["some other error"]
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end
    end
  end

  context 'when the attribute being validated is different than the attribute that receives the validation error' do
    include UnitTests::AllowValueMatcherHelpers

    context 'when the validation error message was provided directly' do
      context 'given a valid value' do
        it 'accepts' do
          builder = builder_for_record_with_different_error_attribute
          expect(builder.record).
            to allow_value(builder.valid_value).
            for(builder.attribute_to_validate).
            with_message(
              builder.message,
              against: builder.attribute_that_receives_error
            )
        end
      end

      context 'given an invalid value' do
        it 'rejects' do
          builder = builder_for_record_with_different_error_attribute
          invalid_value = "#{builder.valid_value} (invalid)"

          expect(builder.record).
            not_to allow_value(invalid_value).
            for(builder.attribute_to_validate).
            with_message(
              builder.message,
              against: builder.attribute_that_receives_error
            )
        end

        context 'if the messages do not match' do
          it 'technically accepts' do
            builder = builder_for_record_with_different_error_attribute(
              message: "a different error"
            )
            invalid_value = "#{builder.valid_value} (invalid)"

            assertion = lambda do
              expect(builder.record).
                not_to allow_value(invalid_value).
                for(builder.attribute_to_validate).
                with_message(
                  "some error",
                  against: builder.attribute_that_receives_error
                )
            end

            message = <<-MESSAGE
After setting :#{builder.attribute_to_validate} to ‹"#{invalid_value}"›, the
matcher expected the #{builder.model.name} to be invalid and to produce the validation
error "some error" on :#{builder.attribute_that_receives_error}. The record was
indeed invalid, but it produced these validation errors instead:

* #{builder.attribute_that_receives_error}: ["a different error"]
            MESSAGE

            expect(&assertion).to fail_with_message(message)
          end
        end
      end
    end

    context 'when the validation error message was provided via i18n' do
      it 'passes given a valid value' do
        builder = builder_for_record_with_different_error_attribute_using_i18n
        expect(builder.record).
          to allow_value(builder.valid_value).
          for(builder.attribute_to_validate).
          with_message(
            builder.validation_message_key,
            against: builder.attribute_that_receives_error
          )
      end

      it 'fails given an invalid value' do
        builder = builder_for_record_with_different_error_attribute_using_i18n
        invalid_value = "#{builder.valid_value} (invalid)"
        expect(builder.record).
          not_to allow_value(invalid_value).
          for(builder.attribute_to_validate).
          with_message(
            builder.validation_message_key,
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
      message = <<-MESSAGE.strip_heredoc
After setting :attr to ‹"12345"›, the matcher expected the Example to be
invalid, but it was valid instead.
      MESSAGE

      assertion = lambda do
        expect(model).not_to allow_value('12345', *bad_values).for(:attr)
      end

      expect(&assertion).to fail_with_message(message)
    end

    it "does not match given bad values along with good values" do
      message = <<-MESSAGE.strip_heredoc
After setting :attr to ‹"12345"›, the matcher expected the Example to be
invalid, but it was valid instead.
      MESSAGE

      assertion = lambda do
        expect(model).not_to allow_value(*bad_values, '12345').for(:attr)
      end

      expect(&assertion).to fail_with_message(message)
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
      context 'when qualified with strict' do
        it 'rejects a bad value, providing the correct failure message' do
          message = <<-MESSAGE.strip_heredoc
After setting :attr to ‹"xyz"›, the matcher expected the Example to be
valid, but it was invalid instead, raising a validation exception with
the message "Attr is invalid".
          MESSAGE

          assertion = lambda do
            expect(validating_format(with: /abc/, strict: true)).
              to allow_value('xyz').for(:attr).strict
          end

          expect(&assertion).to fail_with_message(message)
        end

        context 'qualified with a custom message' do
          it 'rejects a bad value when the failure messages do not match' do
            message = <<-MESSAGE.strip_heredoc
After setting :attr to ‹"xyz"›, the matcher expected the Example to be
invalid and to raise a validation exception with message matching
‹/abc/›. The record was indeed invalid, but the exception message was
"Attr is invalid" instead.
            MESSAGE

            assertion = lambda do
              expect(validating_format(with: /abc/, strict: true)).
                not_to allow_value('xyz').for(:attr).with_message(/abc/).strict
            end

            expect(&assertion).to fail_with_message(message)
          end
        end
      end
    end
  end

  context 'when the attribute interferes with attempts to be set' do
    context 'when the attribute cannot be changed from nil to non-nil' do
      context 'and the record remains valid' do
        it 'accepts (and does not raise an AttributeChangedValueError)' do
          model = define_active_model_class 'Example', accessors: [:name] do
            def name=(_value)
              nil
            end
          end

          expect(model.new).to allow_value('anything').for(:name)
        end
      end

      context 'and the record becomes invalid' do
        it 'rejects with an appropriate failure message' do
          model = define_active_model_class 'Example', accessors: [:name] do
            validates_presence_of :name

            def name=(_value)
              nil
            end
          end

          assertion = lambda do
            expect(model.new).to allow_value('anything').for(:name)
          end

          message = <<-MESSAGE.strip
After setting :name to ‹"anything"› -- which was read back as ‹nil› --
the matcher expected the Example to be valid, but it was invalid
instead, producing these validation errors:

* name: ["can't be blank"]

As indicated in the message above, :name seems to be changing certain
values as they are set, and this could have something to do with why
this test is failing. If you've overridden the writer method for this
attribute, then you may need to change it to make this test pass, or do
something else entirely.
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end
    end

    context 'when the attribute cannot be changed from non-nil to nil' do
      context 'and the record remains valid' do
        it 'accepts (and does not raise an AttributeChangedValueError)' do
          model = define_active_model_class 'Example', accessors: [:name] do
            def name=(value)
              if value
                super(value)
              end
            end
          end

          record = model.new(name: 'some name')

          expect(record).to allow_value(nil).for(:name)
        end
      end

      context 'and the record becomes invalid' do
        it 'rejects with an appropriate failure message' do
          model = define_active_model_class 'Example', accessors: [:name] do
            validates_absence_of :name

            def name=(value)
              if value
                super(value)
              end
            end
          end

          record = model.new(name: 'some name')

          assertion = lambda do
            expect(record).to allow_value(nil).for(:name)
          end

          message = <<-MESSAGE.strip
After setting :name to ‹nil› -- which was read back as ‹"some name"› --
the matcher expected the Example to be valid, but it was invalid
instead, producing these validation errors:

* name: ["must be blank"]

As indicated in the message above, :name seems to be changing certain
values as they are set, and this could have something to do with why
this test is failing. If you've overridden the writer method for this
attribute, then you may need to change it to make this test pass, or do
something else entirely.
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end
    end

    context 'when the attribute cannot be changed from a non-nil value to another non-nil value' do
      context 'and the record remains valid' do
        it 'accepts (and does not raise an AttributeChangedValueError)' do
          model = define_active_model_class 'Example', accessors: [:name] do
            def name=(_value)
              super('constant name')
            end
          end

          record = model.new(name: 'some name')

          expect(record).to allow_value('another name').for(:name)
        end
      end

      context 'and the record becomes invalid' do
        it 'rejects with an appropriate failure message' do
          model = define_active_model_class 'Example', accessors: [:name] do
            validates_format_of :name, with: /another name/

            def name=(value)
              super('constant name')
            end
          end

          record = model.new(name: 'some name')

          assertion = lambda do
            expect(record).to allow_value('another name').for(:name)
          end

          message = <<-MESSAGE.strip
After setting :name to ‹"another name"› -- which was read back as
‹"constant name"› -- the matcher expected the Example to be valid, but
it was invalid instead, producing these validation errors:

* name: ["is invalid"]

As indicated in the message above, :name seems to be changing certain
values as they are set, and this could have something to do with why
this test is failing. If you've overridden the writer method for this
attribute, then you may need to change it to make this test pass, or do
something else entirely.
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end
    end
  end

  context 'when the attribute does not exist on the model' do
    context 'when the assertion is positive' do
      it 'raises an AttributeDoesNotExistError' do
        model = define_class('Example')

        assertion = lambda do
          expect(model.new).to allow_value('foo').for(:nonexistent)
        end

        message = <<-MESSAGE.rstrip
The matcher attempted to set :nonexistent on the Example to "foo", but
that attribute does not exist.
        MESSAGE

        expect(&assertion).to raise_error(
          described_class::AttributeDoesNotExistError,
          message
        )
      end
    end

    context 'when the assertion is negative' do
      it 'raises an AttributeDoesNotExistError' do
        model = define_class('Example')

        assertion = lambda do
          expect(model.new).not_to allow_value('foo').for(:nonexistent)
        end

        message = <<-MESSAGE.rstrip
The matcher attempted to set :nonexistent on the Example to "foo", but
that attribute does not exist.
        MESSAGE

        expect(&assertion).to raise_error(
          described_class::AttributeDoesNotExistError,
          message
        )
      end
    end
  end

  context 'given attributes to preset on the record before validation' do
    context 'when the assertion is positive' do
      context 'if any attributes do not exist on the model' do
        it 'raises an AttributeDoesNotExistError' do
          model = define_active_model_class('Example', accessors: [:existent])

          allow_value_matcher = allow_value('foo').for(:existent).tap do |matcher|
            matcher.values_to_preset = { nonexistent: 'some value' }
          end

          assertion = lambda do
            expect(model.new).to(allow_value_matcher)
          end

          message = <<-MESSAGE.rstrip
The matcher attempted to set :nonexistent on the Example to "some
value", but that attribute does not exist.
        MESSAGE

          expect(&assertion).to raise_error(
            described_class::AttributeDoesNotExistError,
            message
          )
        end
      end
    end

    context 'when the assertion is negative' do
      context 'if any attributes do not exist on the model' do
        it 'raises an AttributeDoesNotExistError' do
          model = define_active_model_class('Example', accessors: [:existent])

          allow_value_matcher = allow_value('foo').for(:existent).tap do |matcher|
            matcher.values_to_preset = { nonexistent: 'some value' }
          end

          assertion = lambda do
            expect(model.new).not_to(allow_value_matcher)
          end

          message = <<-MESSAGE.rstrip
The matcher attempted to set :nonexistent on the Example to "some
value", but that attribute does not exist.
        MESSAGE

          expect(&assertion).to raise_error(
            described_class::AttributeDoesNotExistError,
            message
          )
        end
      end
    end
  end

  if active_record_supports_enum?
    context 'given an ActiveRecord model' do
      context 'where the attribute under test is an enum and the given value is a value in that enum' do
        it 'accepts' do
          model = define_model('Shipment', status: :integer) do
            enum status: { pending: 1, shipped: 2, delivered: 3 }
          end

          expect(model.new).to allow_value(1).for(:status)
        end
      end
    end
  end
end
