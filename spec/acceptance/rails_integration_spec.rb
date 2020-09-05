require 'acceptance_spec_helper'

describe 'shoulda-matchers integrates with Rails' do
  before do
    create_rails_application
    create_files_in_rails_application

    # TODO: ActionController matchers
    # configure_routes_with_single_wildcard_route

    # if rails_gt_5? && bundle.includes?('actiontext')
    #   run_rake_tasks!('action_text:install:migrations')
    # end

    # if rails_gte_5_2? && bundle.includes?('activestorage')
    #   run_rake_tasks!('active_storage:install:migrations')
    # end

    # TODO: Fix uninitialized constant Rails

    run_rake_tasks!('action_text:install:migrations')
    run_rake_tasks!('active_storage:install:migrations')
    run_rake_tasks!('db:drop', 'db:create', 'db:migrate')
  end

  specify 'in a project that uses the default test framework' do
    updating_bundle do
      add_gems_for_n_unit
      add_shoulda_matchers_to_project(
        test_frameworks: [default_test_framework],
        libraries: [:rails],
      )
    end

    run_tests_for_n_unit
  end

  specify 'in a project that uses RSpec' do
    updating_bundle do
      add_gems_for_rspec
      add_shoulda_matchers_to_project(
        test_frameworks: [:rspec],
        libraries: [:rails],
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
        manually: true,
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
        libraries: [:rails],
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
        # ActiveModel matchers
        should allow_value('https://foo.com').for(:website_url)
        should have_secure_password
        should validate_absence_of(:first_name)
        should validate_acceptance_of(:terms_of_service)
        should validate_confirmation_of(:email)
        should validate_exclusion_of(:age).in_array(0..17)
        should validate_inclusion_of(:role).in_array(%w( admin manager ))
        should validate_length_of(:password).is_at_least(10).on(:create)
        should validate_numericality_of(:number_of_dependents).on(:create)
        should validate_presence_of(:email)

        # ActiveRecord matchers
        should have_many(:issues)
        should accept_nested_attributes_for(:issues)
        should belong_to(:organization)
        should define_enum_for(:status)
        should have_and_belong_to_many(:categories)
        should have_db_column(:email)
        should have_db_index(:organization_id)
        should have_implicit_order_column(:created_at)
        should have_many_attached(:photos)
        should have_one(:profile)
        should have_one_attached(:avatar)
        should have_readonly_attribute(:username)
        should have_rich_text(:description)
        should serialize(:social_networks)
        should validate_uniqueness_of(:email)
      end
    FILE

    # TODO: ActionController matchers tests

    result = run_n_unit_test_suite

    expect(result).to indicate_that_tests_were_run(unit: number_of_unit_tests)
  end

  def run_tests_for_rspec
    add_rspec_file 'spec/models/user_spec.rb', <<-FILE
      describe User do
        # ActiveModel matchers
        it { should allow_value('https://foo.com').for(:website_url) }
        it { should have_secure_password }
        it { should validate_absence_of(:first_name) }
        it { should validate_acceptance_of(:terms_of_service) }
        it { should validate_confirmation_of(:email) }
        it { should validate_exclusion_of(:age).in_array(0..17) }
        it { should validate_inclusion_of(:role).in_array(%w( admin manager )) }
        it { should validate_length_of(:password).is_at_least(10).on(:create) }
        it { should validate_numericality_of(:number_of_dependents).on(:create) }
        it { should validate_presence_of(:email) }

        # ActiveRecord matchers
        it { should have_many(:issues) }
        it { should accept_nested_attributes_for(:issues) }
        it { should belong_to(:organization) }
        it { should define_enum_for(:status) }
        it { should have_and_belong_to_many(:categories) }
        it { should have_db_column(:email) }
        it { should have_db_index(:organization_id) }
        it { should have_implicit_order_column(:created_at) } # Rails 6 +
        it { should have_many_attached(:photos) }             # Rails 5.2 +
        it { should have_one(:profile) }
        it { should have_one_attached(:avatar) }              # Rails 5.2 +
        it { should have_readonly_attribute(:username) }
        it { should have_rich_text(:description) }            # Rails 6 +
        it { should serialize(:social_networks) }
        it { should validate_uniqueness_of(:email) }
      end
    FILE

    # TODO: ActionController matchers tests

    result = run_rspec_suite

    expect(result).to have_output("#{number_of_unit_tests} examples, 0 failures")
  end

  # TODO: Change the number depending the rails version
  def number_of_unit_tests
    # if rails_gt_5?
    #   25
    # elsif rails_gte_5_2?
    #   # Note: It should not test:
    #   # - have_implicit_order_column
    #   # - have_rich_text
    #   23
    # else
    #   # Note: It should not test:
    #   # - have_implicit_order_column
    #   # - have_many_attached matchers
    #   # - have_one_attached
    #   # - have_rich_text
    #   21
    # end

    25
  end
end
