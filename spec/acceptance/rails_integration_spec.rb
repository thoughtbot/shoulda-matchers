require 'acceptance_spec_helper'

describe 'shoulda-matchers integrates with Rails' do
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
      end
    FILE

    write_file 'app/controllers/examples_controller.rb', <<-FILE
      class ExamplesController < ApplicationController
        def show
          @example = 'hello'
          render nothing: true
        end
      end
    FILE

    configure_routes_with_single_wildcard_route
  end

  specify 'in a project that uses the default test framework' do
    updating_bundle do
      add_gems_for_n_unit
      add_shoulda_matchers_to_project(
        test_frameworks: [default_test_framework],
        libraries: [:rails]
      )
    end

    run_tests_for_n_unit
  end

  specify 'in a project that uses RSpec' do
    updating_bundle do
      add_gems_for_rspec
      add_shoulda_matchers_to_project(
        test_frameworks: [:rspec],
        libraries: [:rails]
      )
    end

    run_tests_for_rspec
  end

  specify 'in a project that uses Spring' do
    unless bundle_includes?('spring')
      skip "Spring isn't a dependency of this Appraisal"
    end

    updating_bundle do
      add_spring_to_project
      add_gems_for_rspec
      add_shoulda_matchers_to_project(
        test_frameworks: [:rspec],
        libraries: [:rails],
        manually: true
      )
    end

    run_command_within_bundle!('spring stop')

    run_tests_for_rspec
  end

  specify 'in a project that combines both RSpec and Test::Unit' do
    updating_bundle do
      add_gems_for_n_unit
      add_gems_for_rspec
      add_shoulda_matchers_to_project(
        test_frameworks: [:rspec, nil],
        libraries: [:rails]
      )
    end

    run_tests_for_n_unit
    run_tests_for_rspec
  end

  def add_gems_for_n_unit
    add_gem 'shoulda-context'
  end

  def add_gems_for_rspec
    add_rspec_rails_to_project!
  end

  def run_tests_for_n_unit
    write_file 'test/unit/user_test.rb', <<-FILE
      require 'test_helper'

      class UserTest < ActiveSupport::TestCase
        should validate_presence_of(:name)
      end
    FILE

    write_file 'test/functional/examples_controller_test.rb', <<-FILE
      require 'test_helper'

      class ExamplesControllerTest < ActionController::TestCase
        def setup
          get :show
        end

        should respond_with(:success)
      end
    FILE

    result = run_n_unit_test_suite

    expect(result).to indicate_that_tests_were_run(unit: 1, functional: 1)
    expect(result).to have_output(
      'User should validate that :name cannot be empty/falsy'
    )
    expect(result).to have_output('should respond with 200')
  end

  def run_tests_for_rspec
    add_rspec_file 'spec/models/user_spec.rb', <<-FILE
      describe User do
        it { should validate_presence_of(:name) }
      end
    FILE

    add_rspec_file 'spec/controllers/examples_controller_spec.rb', <<-FILE
      describe ExamplesController, "show" do
        before { get :show }

        it { should respond_with(:success) }
      end
    FILE

    result = run_rspec_suite

    expect(result).to have_output('2 examples, 0 failures')
    expect(result).to have_output(
      'should validate that :name cannot be empty/falsy'
    )
    expect(result).to have_output('should respond with 200')
  end
end
