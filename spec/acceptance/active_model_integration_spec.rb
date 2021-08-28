require 'acceptance_spec_helper'

describe 'shoulda-matchers integrates with an ActiveModel project' do

  before do
    create_active_model_project

    write_file 'lib/user.rb', <<-FILE
      require 'active_model'

      class User
        include ActiveModel::Validations
        attr_accessor :gender

        validates :gender, inclusion: { in: %w(male female) }
      end
    FILE

    write_file 'spec/user_spec.rb', <<-FILE
      require 'spec_helper'
      require 'user'
      include Shoulda::Matchers::ActiveModel

      describe User do
        context 'when gender is valid' do
          it { is_expected.to validate_inclusion_of(:gender).in_array(%w(male female)) }
        end
        context 'when gender is invalid' do
          it { is_expected.to validate_inclusion_of(:gender).in_array(%w(transgender female)) }
        end
      end
    FILE

    write_file 'load_dependencies.rb', <<-FILE
      require 'active_model'
      require 'shoulda-matchers'

      puts ActiveModel::VERSION::STRING
      puts "Loaded all dependencies without errors"
    FILE

    updating_bundle do
      add_rspec_to_project
      add_shoulda_matchers_to_project(
        manually: true,
        with_configuration: false,
      )

      write_file 'spec/spec_helper.rb', <<-FILE
        require 'active_model'
        require 'shoulda-matchers'

        Shoulda::Matchers.configure do |config|
          config.integrate do |with|
            with.test_framework :rspec

            with.library :active_model
          end
        end
      FILE
    end
  end

  context 'when using active model library' do

    it 'and loads without errors' do
      result = run_command_within_bundle('ruby load_dependencies.rb')
      expect(result).to have_output('Loaded all dependencies without errors')
    end

    it 'allows use of inclusion matcher from active model library' do
      result = run_rspec_tests('spec/user_spec.rb')
      expect(result).to have_output('2 examples, 1 failure')

      expect(result).to have_output(
        'gender: ["is not included in the list"]',
      )
    end
  end

end
