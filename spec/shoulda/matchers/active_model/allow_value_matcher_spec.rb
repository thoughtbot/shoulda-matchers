require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::AllowValueMatcher do
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
        not_to allow_value('xyz', 'zyx', nil, []).for(:attr)
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

  context 'an attribute where the message occurs on another attribute' do
    it 'allows a good value' do
      expect(record_with_custom_validation).to \
        allow_value('good value').for(:attr).with_message(/some message/, against: :attr2)
    end

    it 'rejects a bad value' do
      expect(record_with_custom_validation).not_to \
        allow_value('bad value').for(:attr).with_message(/some message/, against: :attr2)
    end

    def record_with_custom_validation
      define_model :example, attr: :string, attr2: :string do
        validate :custom_validation

        def custom_validation
          if self[:attr] != 'good value'
            self.errors[:attr2] << 'some message'
          end
        end
      end.new
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

    it 'allows a good value' do
      expect(model).to allow_value('12345').for(:attr)
    end

    bad_values.each do |bad_value|
      it "rejects a bad value (#{bad_value.inspect})" do
        expect(model).not_to allow_value(bad_value).for(:attr)
      end
    end

    it "rejects several bad values (#{bad_values.map(&:inspect).join(', ')})" do
      expect(model).not_to allow_value(*bad_values).for(:attr)
    end

    it "rejects a mix of both good and bad values" do
      expect(model).not_to allow_value('12345', *bad_values).for(:attr)
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

        expect(matcher.failure_message_when_negated).to eq 'Expected exception to include /abc/ ' +
          'when attr is set to "xyz", got Attr is invalid'
      end
    end
  end
end
