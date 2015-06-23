require 'acceptance_spec_helper'

describe 'shoulda-matchers integrates libs for rspec-expectations framework' do
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

    append_rake_task 'rspec_exp', 'environment', <<-CODE
  require 'rspec/expectations'
  require 'shoulda-matchers'
  require_relative 'test/test_helper.rb'

  def expect(value, &block)
    ::RSpec::Expectations::ExpectationTarget.for(value, block)
  end

  def validate_presence_of(value)
    ::ActiveSupport::TestCase.validate_presence_of(value)
  end

  it = User.create name: 'Vasja'
  expect(User.first).to validate_presence_of(:name)
  puts "Passed"
    CODE

    updating_bundle do
      add_rspec_expectations_to_project!
      add_shoulda_matchers_to_project(
        test_frameworks: [:rspec_exp],
        libraries: [:active_record, :active_model],
      )
    end
  end

  context 'when using both active_record and active_model libraries' do
    it 'allows the use of matchers from both libraries' do
      result = run_rake_tasks 'rspec_exp'
      expect(result).to have_output('Passed')
    end
  end
end
