require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveRecord::EncryptMatcher, type: :model do
  if rails_version >= 7.0
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
  end
end
