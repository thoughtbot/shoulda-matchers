require 'acceptance_spec_helper'

describe 'shoulda-matchers integrates with multiple libraries' do
  before do
    create_rails_application

    write_file 'db/migrate/1_create_users.rb', <<-FILE
      class CreateUsers < ActiveRecord::Migration
        def self.up
          create_table :users do |t|
            t.string :name
          end
        end
      end
    FILE

    run_rake_tasks!(*%w(db:drop db:create db:migrate))

    write_file 'app/models/user.rb', <<-FILE
      class User < ActiveRecord::Base
        validates_presence_of :name
        validates_uniqueness_of :name
      end
    FILE

    add_rspec_file 'spec/models/user_spec.rb', <<-FILE
      describe User do
        subject { User.new(name: "John Smith") }
        it { should validate_presence_of(:name) }
        it { should validate_uniqueness_of(:name) }
      end
    FILE

    updating_bundle do
      add_rspec_rails_to_project!
      add_shoulda_matchers_to_project(
        test_frameworks: [:rspec],
        libraries: [:active_record, :active_model]
      )
    end
  end

  context 'when using both active_record and active_model libraries' do
    it 'allows the use of matchers from both libraries' do
      result = run_rspec_suite
      expect(result).to have_output('2 examples, 0 failures')
      expect(result).to have_output(
        'should validate that :name cannot be empty/falsy'
      )
      expect(result).to have_output(
        'should validate that :name is case-sensitively unique'
      )
    end
  end
end
