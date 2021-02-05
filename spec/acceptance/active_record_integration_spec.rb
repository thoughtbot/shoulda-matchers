require 'acceptance_spec_helper'

describe 'shoulda-matchers integrates with active record' do
  before do
    create_active_record_project

    write_file 'Rakefile', <<-FILE
      require 'active_record'
      require 'sqlite3'

      namespace :db do
        desc 'Create the database'
        task :create do
          File.unlink 'test.sqlite3' if File.exist?('test.sqlite3')
          db = SQLite3::Database.new('test.sqlite3')
          db.execute("CREATE TABLE users (id integer)")
          db.execute("CREATE TABLE profiles (id integer, user_id integer)")
        end
      end
    FILE

    run_rake_tasks!('db:create')

    write_file 'lib/user.rb', <<-FILE
      require 'active_record'

      class User < ActiveRecord::Base
      end
    FILE

    write_file 'lib/profile.rb', <<-FILE
      require 'active_record'
      require 'user'

      class Profile < ActiveRecord::Base
        belongs_to :user
        validates_presence_of :user
      end
    FILE

    write_file 'spec/profile_spec.rb', <<-FILE
      require 'spec_helper'
      require 'profile'

      describe Profile, type: :model do
        it { should validate_presence_of(:user) }
      end
    FILE

    updating_bundle do
      add_rspec_to_project
      add_shoulda_matchers_to_project(
        manually: true,
        with_configuration: false,
      )

      write_file 'spec/spec_helper.rb', <<-FILE
        require 'active_record'
        require 'shoulda-matchers'

        RSpec.configure do |config|
          config.before(:suite) do
            ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'test.sqlite3')
          end
        end

        Shoulda::Matchers.configure do |config|
          config.integrate do |with|
            with.test_framework :rspec

            with.library :active_record
            with.library :active_model
          end
        end
      FILE
    end
  end

  context 'when using both active_record and active_model libraries' do
    it 'allows the use of matchers from both libraries' do
      result = run_rspec_tests('spec/profile_spec.rb')

      expect(result).to have_output('1 example, 0 failures')
      expect(result).to have_output(
        'is expected to validate that :user cannot be empty/falsy',
      )
    end
  end
end
