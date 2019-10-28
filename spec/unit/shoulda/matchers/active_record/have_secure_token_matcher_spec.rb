require 'unit_spec_helper'

# rubocop:disable Metrics/BlockLength
describe Shoulda::Matchers::ActiveRecord::HaveSecureTokenMatcher,
  type: :model do

  if active_record_supports_has_secure_token?
    describe '#description' do
      it 'returns the message including the name of the default column' do
        matcher = have_secure_token
        expect(matcher.description).
          to eq('have :token as a secure token')
      end

      it 'returns the message including the name of a provided column' do
        matcher = have_secure_token(:special_token)
        expect(matcher.description).
          to eq('have :special_token as a secure token')
      end
    end

    it 'matches when the subject configures has_secure_token with the db' do
      create_table(:users) do |t|
        t.string :token
        t.index :token, unique: true
      end

      valid_model = define_model_class(:User) { has_secure_token }

      expect(valid_model.new).to have_secure_token
    end

    it 'matches when the subject configures has_secure_token with the db for ' \
       'a custom attribute' do
      create_table(:users) do |t|
        t.string :auth_token
        t.index :auth_token, unique: true
      end

      valid_model = define_model_class(:User) { has_secure_token(:auth_token) }
      expect(valid_model.new).to have_secure_token(:auth_token)
    end

    it 'does not match when missing an token index' do
      create_table(:users) do |t|
        t.string :token
      end

      invalid_model = define_model_class(:User) { has_secure_token }
      expected_message =
        'Expected User to have :token as a secure token but the following ' \
        'errors were found: missing unique index for users.token'

      aggregate_failures do
        expect(invalid_model.new).not_to have_secure_token
        expect { expect(invalid_model.new).to have_secure_token }.
          to fail_with_message(expected_message)
      end
    end

    it 'does not match when missing a token column' do
      create_table(:users)
      invalid_model = define_model_class(:User) { has_secure_token }

      expected_message =
        'Expected User to have :token as a secure token but the following ' \
        'errors were found: missing expected class and instance methods, ' \
        'missing correct column token:string, missing unique index for ' \
        'users.token'

      aggregate_failures do
        expect(invalid_model.new).not_to have_secure_token
        expect { expect(invalid_model.new).to have_secure_token }.
          to fail_with_message(expected_message)
      end
    end

    it 'does not match when when lacking has_secure_token' do
      create_table(:users) do |t|
        t.string :token
        t.index :token
      end

      invalid_model = define_model_class(:User)

      expected_message =
        'Expected User to have :token as a secure token but the following ' \
        'errors were found: missing expected class and instance methods, ' \
        'missing unique index for users.token'

      aggregate_failures do
        expect(invalid_model.new).not_to have_secure_token
        expect { expect(invalid_model.new).to have_secure_token }.
          to fail_with_message(expected_message)
      end
    end

    it 'does not match when missing an index for a custom attribute' do
      create_table(:users) do |t|
        t.string :auth_token
      end

      invalid_model = define_model_class(:User) do
        has_secure_token(:auth_token)
      end

      expected_message =
        'Expected User to have :auth_token as a secure token but the ' \
        'following errors were found: missing unique index for ' \
        'users.auth_token'

      aggregate_failures do
        expect(invalid_model.new).not_to have_secure_token(:auth_token)
        expect { expect(invalid_model.new).to have_secure_token(:auth_token) }.
          to fail_with_message(expected_message)
      end
    end

    it 'does not match when missing a column for a custom attribute' do
      create_table(:users)
      invalid_model = define_model_class(:User) do
        has_secure_token(:auth_token)
      end

      expected_message =
        'Expected User to have :auth_token as a secure token but the ' \
        'following errors were found: missing expected class and instance '  \
        'methods, missing correct column auth_token:string, missing unique ' \
        'index for users.auth_token'

      aggregate_failures do
        expect(invalid_model.new).not_to have_secure_token(:auth_token)
        expect { expect(invalid_model.new).to have_secure_token(:auth_token) }.
          to fail_with_message(expected_message)
      end
    end

    it 'does not match when when lacking has_secure_token for the attribute' do
      create_table(:users) do |t|
        t.string :auth_token
        t.index :auth_token, unique: true
      end

      invalid_model = define_model_class(:User)
      expected_message =
        'Expected User to have :auth_token as a secure token but the ' \
        'following errors were found: missing expected class and instance ' \
        'methods'

      aggregate_failures do
        expect(invalid_model.new).not_to have_secure_token(:auth_token)
        expect { expect(invalid_model.new).to have_secure_token(:auth_token) }.
          to fail_with_message(expected_message)
      end
    end

    it 'fails with the appropriate message when negated' do
      create_table(:users) do |t|
        t.string :token
        t.index :token, unique: true
      end

      valid_model = define_model_class(:User) { has_secure_token }

      expect { expect(valid_model.new).not_to have_secure_token }.
        to fail_with_message('Did not expect User to have secure token :token')
    end
  end
end
