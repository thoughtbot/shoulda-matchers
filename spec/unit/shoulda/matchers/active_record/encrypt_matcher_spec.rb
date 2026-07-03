require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveRecord::EncryptMatcher, type: :model do
  context 'a encrypt attribute' do
    it 'accepts' do
      expect(with_encrypt_attr).to encrypt(:attr)
    end

    it 'rejects when used in the negative' do
      assertion = lambda do
        expect(with_encrypt_attr).not_to encrypt(:attr)
      end

      expect(&assertion).to fail_with_message(<<~MESSAGE)
Did not expect to encrypt :attr of Example,
but it did
      MESSAGE
    end
  end

  context 'an attribute that is not part of the encrypted-attributes set' do
    it 'rejects being encrypted' do
      model = define_model :example, attr: :string, other: :string do
        encrypts :attr
      end.new

      expect(model).not_to encrypt(:other)
    end

    context 'an attribute on a class with no encrypt attributes' do
      it 'rejects being encrypted' do
        expect(define_model(:example, attr: :string).new).
          not_to encrypt(:attr)
      end

      it 'assigns a failure message' do
        model = define_model(:example, attr: :string).new

        assertion = lambda do
          expect(model).to encrypt(:attr)
        end

        expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected to encrypt :attr of Example, but it did not
        MESSAGE
      end
    end

    context 'deterministic' do
      it 'default value is false' do
        expect(with_encrypt_attr).to encrypt(:attr).deterministic(false)
      end

      it 'accepts a valid truthy value' do
        expect(with_encrypt_attr(deterministic: true)).to encrypt(:attr).deterministic(true)
      end

      it 'accepts a valid falsey value' do
        expect(with_encrypt_attr(deterministic: false)).to encrypt(:attr).deterministic(false)
      end

      it 'rejects an invalid truthy value' do
        assertion = lambda do
          expect(with_encrypt_attr(deterministic: true)).to encrypt(:attr).deterministic(false)
        end

        expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected to encrypt :attr of Example using :deterministic option
as ‹false›, but got ‹true›
        MESSAGE
      end

      it 'rejects an invalid falsey value' do
        assertion = lambda do
          expect(with_encrypt_attr).to encrypt(:attr).deterministic(true)
        end

        expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected to encrypt :attr of Example using :deterministic option
as ‹true›, but got ‹false›
        MESSAGE
      end

      it 'rejects when used in the negative' do
        assertion = lambda do
          expect(with_encrypt_attr(deterministic: true)).not_to encrypt(:attr).deterministic(true)
        end

        expect(&assertion).to fail_with_message(<<~MESSAGE)
Did not expect to encrypt :attr of Example
using :deterministic option as ‹true›,
but it did
        MESSAGE
      end
    end

    context 'downcase' do
      it 'default value is false' do
        expect(with_encrypt_attr).to encrypt(:attr).downcase(false)
      end

      it 'accepts a valid truthy value' do
        expect(with_encrypt_attr(downcase: true)).to encrypt(:attr).downcase(true)
      end

      it 'accepts a valid falsey value' do
        expect(with_encrypt_attr(downcase: false)).to encrypt(:attr).downcase(false)
      end

      it 'rejects an invalid truthy value' do
        assertion = lambda do
          expect(with_encrypt_attr(downcase: true)).to encrypt(:attr).downcase(false)
        end

        expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected to encrypt :attr of Example using :downcase option
as ‹false›, but got ‹true›
        MESSAGE
      end

      it 'rejects an invalid falsey value' do
        assertion = lambda do
          expect(with_encrypt_attr).to encrypt(:attr).downcase(true)
        end

        expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected to encrypt :attr of Example using :downcase option
as ‹true›, but got ‹false›
        MESSAGE
      end

      it 'rejects when used in the negative' do
        assertion = lambda do
          expect(with_encrypt_attr(downcase: true)).not_to encrypt(:attr).downcase(true)
        end

        expect(&assertion).to fail_with_message(<<~MESSAGE)
Did not expect to encrypt :attr of Example
using :downcase option as ‹true›,
but it did
        MESSAGE
      end
    end

    context 'ignore_case' do
      it 'default value is false' do
        expect(with_encrypt_attr).to encrypt(:attr).ignore_case(false)
      end

      it 'accepts a valid truthy value' do
        expect(with_encrypt_ignore_case_attr).to encrypt(:attr).ignore_case(true)
      end

      it 'accepts a valid falsey value' do
        expect(with_encrypt_attr(ignore_case: false)).to encrypt(:attr).ignore_case(false)
      end

      it 'rejects an invalid truthy value' do
        assertion = lambda do
          expect(with_encrypt_ignore_case_attr).to encrypt(:attr).ignore_case(false)
        end

        expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected to encrypt :attr of Example using :ignore_case option
as ‹false›, but got ‹true›
        MESSAGE
      end

      it 'rejects an invalid falsey value' do
        assertion = lambda do
          expect(with_encrypt_attr(deterministic: true, ignore_case: false)).to encrypt(:attr).ignore_case(true)
        end

        expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected to encrypt :attr of Example using :ignore_case option
as ‹true›, but got ‹false›
        MESSAGE
      end

      it 'rejects when used in the negative' do
        assertion = lambda do
          expect(with_encrypt_ignore_case_attr).not_to encrypt(:attr).deterministic(true).ignore_case(true)
        end

        expect(&assertion).to fail_with_message(<<~MESSAGE)
Did not expect to encrypt :attr of Example
using :deterministic option as ‹true› and
:ignore_case option as ‹true›,
but it did
        MESSAGE
      end
    end

    context 'with_key_provider' do
      it 'accepts when the key provider matches' do
        key_provider = build_key_provider

        expect(with_encrypt_attr(key_provider: key_provider)).
          to encrypt(:attr).with_key_provider(key_provider)
      end

      it 'accepts when given the key provider class' do
        expect(with_encrypt_attr(key_provider: build_key_provider)).
          to encrypt(:attr).
          with_key_provider(ActiveRecord::Encryption::KeyProvider)
      end

      it 'rejects when given a non-matching key provider class' do
        key_provider = build_key_provider
        expected = ActiveRecord::Encryption::DerivedSecretKeyProvider

        assertion = lambda do
          expect(with_encrypt_attr(key_provider: key_provider)).
            to encrypt(:attr).with_key_provider(expected)
        end

        expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected to encrypt :attr of Example using :key_provider option
as ‹#{expected}›, but got ‹#{key_provider}›
        MESSAGE
      end

      it 'rejects when the key provider does not match' do
        key_provider = build_key_provider
        expected = build_key_provider

        assertion = lambda do
          expect(with_encrypt_attr(key_provider: key_provider)).
            to encrypt(:attr).with_key_provider(expected)
        end

        expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected to encrypt :attr of Example using :key_provider option
as ‹#{expected}›, but got ‹#{key_provider}›
        MESSAGE
      end

      it 'rejects when used in the negative' do
        key_provider = build_key_provider

        assertion = lambda do
          expect(with_encrypt_attr(key_provider: key_provider)).
            not_to encrypt(:attr).with_key_provider(key_provider)
        end

        expect(&assertion).to fail_with_message(<<~MESSAGE)
Did not expect to encrypt :attr of Example
using :key_provider option as ‹#{key_provider}›,
but it did
        MESSAGE
      end
    end

    context 'with_previous' do
      it 'accepts when the previous schemes match' do
        expect(with_encrypt_attr(previous: { deterministic: true })).
          to encrypt(:attr).with_previous(deterministic: true)
      end

      it 'rejects when the previous schemes do not match' do
        expected = [{ deterministic: false }]
        actual = [{ deterministic: true }]

        assertion = lambda do
          expect(with_encrypt_attr(previous: { deterministic: true })).
            to encrypt(:attr).with_previous(deterministic: false)
        end

        expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected to encrypt :attr of Example using :previous option
as ‹#{expected}›, but got ‹#{actual}›
        MESSAGE
      end

      it 'rejects when used in the negative' do
        previous = [{ deterministic: true }]

        assertion = lambda do
          expect(with_encrypt_attr(previous: { deterministic: true })).
            not_to encrypt(:attr).with_previous(deterministic: true)
        end

        expect(&assertion).to fail_with_message(<<~MESSAGE)
Did not expect to encrypt :attr of Example
using :previous option as ‹#{previous}›,
but it did
        MESSAGE
      end
    end

    context 'with_compressor' do
      it 'accepts when the compressor matches' do
        compressor = Module.new

        expect(with_encrypt_attr(compressor: compressor)).
          to encrypt(:attr).with_compressor(compressor)
      end

      it 'rejects when the compressor does not match' do
        expected = Module.new
        actual = Module.new

        assertion = lambda do
          expect(with_encrypt_attr(compressor: actual)).
            to encrypt(:attr).with_compressor(expected)
        end

        expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected to encrypt :attr of Example using :compressor option
as ‹#{expected}›, but got ‹#{actual}›
        MESSAGE
      end

      it 'rejects when used in the negative' do
        compressor = Module.new

        assertion = lambda do
          expect(with_encrypt_attr(compressor: compressor)).
            not_to encrypt(:attr).with_compressor(compressor)
        end

        expect(&assertion).to fail_with_message(<<~MESSAGE)
Did not expect to encrypt :attr of Example
using :compressor option as ‹#{compressor}›,
but it did
        MESSAGE
      end
    end

    context 'without_compression' do
      it 'accepts when compression is disabled' do
        expect(with_encrypt_attr(compress: false)).
          to encrypt(:attr).without_compression
      end

      it 'rejects when compression is enabled' do
        assertion = lambda do
          expect(with_encrypt_attr).to encrypt(:attr).without_compression
        end

        expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected to encrypt :attr of Example using :compress option
as ‹false›, but got ‹true›
        MESSAGE
      end

      it 'rejects when used in the negative' do
        assertion = lambda do
          expect(with_encrypt_attr(compress: false)).
            not_to encrypt(:attr).without_compression
        end

        expect(&assertion).to fail_with_message(<<~MESSAGE)
Did not expect to encrypt :attr of Example
using :compress option as ‹false›,
but it did
        MESSAGE
      end
    end

    context 'supporting_unencrypted_data' do
      it 'accepts when the attribute supports unencrypted data' do
        expect(with_encrypt_attr(support_unencrypted_data: true)).
          to encrypt(:attr).supporting_unencrypted_data
      end

      it 'rejects when the attribute does not support unencrypted data' do
        assertion = lambda do
          expect(with_encrypt_attr(support_unencrypted_data: false)).
            to encrypt(:attr).supporting_unencrypted_data
        end

        expect(&assertion).to fail_with_message(<<~MESSAGE)
Expected to encrypt :attr of Example using :support_unencrypted_data option
as ‹true›, but got ‹false›
        MESSAGE
      end

      it 'rejects when used in the negative' do
        assertion = lambda do
          expect(with_encrypt_attr(support_unencrypted_data: true)).
            not_to encrypt(:attr).supporting_unencrypted_data
        end

        expect(&assertion).to fail_with_message(<<~MESSAGE)
Did not expect to encrypt :attr of Example
using :support_unencrypted_data option as ‹true›,
but it did
        MESSAGE
      end
    end
  end

  def with_encrypt_attr(**options)
    define_model :example, attr: :string do
      encrypts :attr, **options
    end.new
  end

  def with_encrypt_ignore_case_attr(**options)
    define_model :example, attr: :string, original_attr: :string do
      encrypts :attr, deterministic: true, ignore_case: true, **options
    end.new
  end

  def build_key_provider
    ActiveRecord::Encryption::KeyProvider.new(
      ActiveRecord::Encryption::Key.new(SecureRandom.hex(16)),
    )
  end
end
