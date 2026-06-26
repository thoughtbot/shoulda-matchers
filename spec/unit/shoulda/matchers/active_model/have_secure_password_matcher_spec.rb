require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel::HaveSecurePasswordMatcher, type: :model do
  context 'with no arguments passed to has_secure_password' do
    it 'matches when the subject configures has_secure_password with default options' do
      working_model = define_model(:example, password_digest: :string) { has_secure_password }
      expect(working_model.new).to have_secure_password
    end

    it 'does not match when the subject does not authenticate a password' do
      no_secure_password = define_model(:example)
      expect(no_secure_password.new).not_to have_secure_password
    end

    it 'does not match when the subject is missing the password_digest attribute' do
      no_digest_column = define_model(:example) { has_secure_password }
      expect(no_digest_column.new).not_to have_secure_password
    end
  end

  context 'with the without_validations qualifier' do
    it 'matches when has_secure_password is declared with validations: false' do
      working_model = define_model(:example, password_digest: :string) do
        has_secure_password validations: false
      end
      expect(working_model.new).to have_secure_password.without_validations
    end

    it 'does not match when the password validations are present' do
      working_model = define_model(:example, password_digest: :string) do
        has_secure_password
      end
      expect(working_model.new).not_to have_secure_password.without_validations
    end

    it 'matches when the model opts out but defines its own validations' do
      working_model = define_model(:example, password_digest: :string) do
        has_secure_password validations: false
        validates :password, presence: true
      end
      expect(working_model.new).to have_secure_password.without_validations
    end

    it 'rejects with an appropriate failure message' do
      working_model = define_model(:example, password_digest: :string) do
        has_secure_password
      end
      assertion = lambda do
        expect(working_model.new).to have_secure_password.without_validations
      end

      message = 'expected Example to have a secure password without'\
        ' validations on password, but the built-in validations were present'

      expect(&assertion).to fail_with_message_including(message)
    end
  end

  if rails_gt_8_0?
    context 'with the with_reset_token qualifier' do
      it 'matches when has_secure_password generates a reset token' do
        working_model = define_model(:example, password_digest: :string) do
          has_secure_password
        end
        expect(working_model.new).to have_secure_password.with_reset_token
      end

      it 'does not match when the reset token is disabled' do
        working_model = define_model(:example, password_digest: :string) do
          has_secure_password reset_token: false
        end
        expect(working_model.new).
          not_to have_secure_password.with_reset_token
      end

      # The configurable reset token expiry (and the
      # `<attr>_reset_token_expires_in` reader it relies on) was introduced in
      # Rails 8.1. Remove this version split once support for Rails 8.0 is
      # dropped.
      if rails_version >= '8.1'
        it 'matches when the reset token expiry matches expires_in' do
          working_model = define_model(:example, password_digest: :string) do
            has_secure_password reset_token: { expires_in: 1.hour }
          end
          expect(working_model.new).
            to have_secure_password.with_reset_token(expires_in: 1.hour)
        end

        it 'does not match when the reset token expiry differs' do
          working_model = define_model(:example, password_digest: :string) do
            has_secure_password
          end
          expect(working_model.new).
            not_to have_secure_password.with_reset_token(expires_in: 1.hour)
        end

        it 'rejects with an appropriate failure message for a wrong expiry' do
          working_model = define_model(:example, password_digest: :string) do
            has_secure_password
          end
          assertion = lambda do
            expect(working_model.new).
              to have_secure_password.with_reset_token(expires_in: 1.hour)
          end

          expect(&assertion).to fail_with_message_including('reset token')
        end
      else
        it 'raises an error when expires_in is used on Rails older than 8.1' do
          working_model = define_model(:example, password_digest: :string) do
            has_secure_password
          end
          assertion = lambda do
            expect(working_model.new).
              to have_secure_password.with_reset_token(expires_in: 1.hour)
          end

          expect(&assertion).to raise_error(/Rails 8\.1/)
        end
      end
    end

    context 'with the without_reset_token qualifier' do
      it 'matches when the reset token is disabled' do
        working_model = define_model(:example, password_digest: :string) do
          has_secure_password reset_token: false
        end
        expect(working_model.new).to have_secure_password.without_reset_token
      end

      it 'does not match when a reset token is generated' do
        working_model = define_model(:example, password_digest: :string) do
          has_secure_password
        end
        expect(working_model.new).
          not_to have_secure_password.without_reset_token
      end
    end
  else
    # The reset token feature was introduced in Rails 8.0. Remove this branch
    # (and keep only the qualifier specs above) once support for Rails 7.2 is
    # dropped.
    context 'with reset token qualifiers on Rails older than 8.0' do
      it 'raises an error when with_reset_token is used' do
        working_model = define_model(:example, password_digest: :string) do
          has_secure_password
        end
        assertion = lambda do
          expect(working_model.new).to have_secure_password.with_reset_token
        end

        expect(&assertion).to raise_error(/Rails 8\.0/)
      end

      it 'raises an error when without_reset_token is used' do
        working_model = define_model(:example, password_digest: :string) do
          has_secure_password
        end
        assertion = lambda do
          expect(working_model.new).to have_secure_password.without_reset_token
        end

        expect(&assertion).to raise_error(/Rails 8\.0/)
      end
    end
  end

  context 'when custom attribute is given to has_secure_password' do
    it 'matches when the subject configures has_secure_password with correct options' do
      working_model = define_model(:example, reset_password_digest: :string) { has_secure_password :reset_password }
      expect(working_model.new).to have_secure_password :reset_password
    end

    it 'does not match when the subject does not authenticate a password' do
      no_secure_password = define_model(:example)
      expect(no_secure_password.new).not_to have_secure_password :reset_password
    end

    it 'does not match when the subject is missing the custom digest attribute' do
      no_digest_column = define_model(:example) { has_secure_password :reset_password }
      expect(no_digest_column.new).not_to have_secure_password :reset_password
    end

    it 'rejects with an appropriate failure message' do
      working_model = define_model(:example, reset_password_digest: :string) { has_secure_password :reset_password }
      assertion = lambda do
        expect(working_model.new).not_to have_secure_password :reset_password
      end

      message = <<-MESSAGE
expected Example to not have a secure password, defined on reset_password attribute!
      MESSAGE

      expect(&assertion).to fail_with_message(message)
    end
  end
end
