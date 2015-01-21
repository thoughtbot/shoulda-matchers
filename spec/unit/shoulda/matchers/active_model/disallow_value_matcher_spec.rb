require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel::DisallowValueMatcher, type: :model do
  context 'an attribute with a format validation' do
    it 'does not match if the value is allowed' do
      expect(validating_format(with: /abc/)).not_to matcher('abcde').for(:attr)
    end

    it 'matches if the value is not allowed' do
      expect(validating_format(with: /abc/)).to matcher('xyz').for(:attr)
    end
  end

  context "an attribute with a context-dependent validation" do
    context "without the validation context" do
      it "does not match" do
        expect(validating_format(with: /abc/, on: :customisable)).not_to matcher("xyz").for(:attr)
      end
    end

    context "with the validation context" do
      it "disallows a bad value" do
        expect(validating_format(with: /abc/, on: :customisable)).to matcher("xyz").for(:attr).on(:customisable)
      end

      it "does not match a good value" do
        expect(validating_format(with: /abc/, on: :customisable)).not_to matcher("abcde").for(:attr).on(:customisable)
      end
    end
  end

  context 'an attribute with a format validation and a custom message' do
    it 'does not match if the value and message are both correct' do
      expect(validating_format(with: /abc/, message: 'good message')).
        not_to matcher('abcde').for(:attr).with_message('good message')
    end

    it "delegates its failure message to its allow matcher's negative failure message" do
      allow_matcher = double('allow_matcher',
        failure_message_when_negated: 'allow matcher failure',
      ).as_null_object
      allow(Shoulda::Matchers::ActiveModel::AllowValueMatcher).
        to receive(:new).
        and_return(allow_matcher)

      matcher = matcher('abcde').for(:attr).with_message('good message')
      matcher.matches?(validating_format(with: /abc/, message: 'good message'))

      expect(matcher.failure_message).to eq 'allow matcher failure'
    end

    it 'matches if the message is correct but the value is not' do
      expect(validating_format(with: /abc/, message: 'good message')).
        to matcher('xyz').for(:attr).with_message('good message')
    end
  end

  context 'an attribute where the message occurs on another attribute' do
    it 'matches if the message is correct but the value is not' do
      expect(record_with_custom_validation).to \
        matcher('bad value').for(:attr).with_message(/some message/, against: :attr2)
    end

    it 'does not match if the value and message are both correct' do
      expect(record_with_custom_validation).not_to \
        matcher('good value').for(:attr).with_message(/some message/, against: :attr2)
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

  if active_record_can_raise_range_error?
    context 'when the value is outside of the range of the column' do
      context 'not qualified with strict' do
        it 'accepts, failing with the correct message' do
          attribute_options = { type: :integer, options: { limit: 2 } }
          record = define_model(:example, attr: attribute_options).new
          assertion = -> { expect(record).not_to disallow_value(100000).for(:attr) }
          message = <<-MESSAGE.strip_heredoc.strip
            Did not expect errors when attr is set to 100000,
            got RangeError: "100000 is out of range for ActiveRecord::Type::Integer with limit 2"
          MESSAGE
          expect(&assertion).to fail_with_message(message)
        end

        context 'qualified with a message' do
          it 'ignores any specified message, failing with the correct message' do
            attribute_options = { type: :integer, options: { limit: 2 } }
            record = define_model(:example, attr: attribute_options).new
            assertion = -> do
              expect(record).
                not_to disallow_value(100000).
                for(:attr).
                with_message('some message')
            end
            message = <<-MESSAGE.strip_heredoc.strip
              Did not expect errors to include "some message" when attr is set to 100000,
              got RangeError: "100000 is out of range for ActiveRecord::Type::Integer with limit 2"
            MESSAGE
            expect(&assertion).to fail_with_message(message)
          end
        end
      end

      if active_model_supports_strict?
        context 'qualified with strict' do
          it 'accepts, failing with the correct message' do
            attribute_options = { type: :integer, options: { limit: 2 } }
            record = define_model(:example, attr: attribute_options).new
            assertion = -> do
              expect(record).
                not_to disallow_value(100000).
                for(:attr).
                strict
            end
            message = <<-MESSAGE.strip_heredoc.strip
              Did not expect an exception to have been raised when attr is set to 100000,
              got RangeError: "100000 is out of range for ActiveRecord::Type::Integer with limit 2"
            MESSAGE
            expect(&assertion).to fail_with_message(message)
          end

          context 'qualified with a message' do
            it 'ignores any specified message' do
              attribute_options = { type: :integer, options: { limit: 2 } }
              record = define_model(:example, attr: attribute_options).new
              assertion = -> do
                expect(record).
                  not_to disallow_value(100000).
                  for(:attr).
                  with_message('some message').
                  strict
              end
              message = <<-MESSAGE.strip_heredoc.strip
                Did not expect exception to include "some message" when attr is set to 100000,
                got RangeError: "100000 is out of range for ActiveRecord::Type::Integer with limit 2"
              MESSAGE
              expect(&assertion).to fail_with_message(message)
            end
          end
        end
      end
    end
  end

  def matcher(value)
    described_class.new(value)
  end
  alias_method :disallow_value, :matcher
end
