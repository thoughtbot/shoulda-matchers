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
