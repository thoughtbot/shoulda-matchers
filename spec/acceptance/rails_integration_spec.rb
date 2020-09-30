require 'acceptance_spec_helper'

describe 'shoulda-matchers integrates with Rails' do
  before do
    create_rails_application
    create_files_in_rails_application

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
    create_files_for_minitest

    result = run_n_unit_test_suite

    expect(result).to indicate_that_tests_were_run(unit: number_of_unit_tests, functional: number_of_functional_tests)
  end

  def run_tests_for_rspec
    create_files_for_rspec

    result = run_rspec_suite

    expect(result).to have_output("#{tests_count} examples, 0 failures")
  end

  def tests_count
    number_of_unit_tests + number_of_functional_tests
  end

  let(:number_of_functional_tests) { 3 }
end
