require 'acceptance_spec_helper'

describe 'Developer fails to require libraries or test frameworks manually' do
  context 'using Minitest' do
    def any_library
      # Just choose one arbitrarily
      :active_model
    end

    def create_minitest_project(libraries: [any_library])
      create_generic_bundler_project

      updating_bundle do
        yield
        add_shoulda_matchers_to_project(
          test_frameworks: [default_test_framework],
          libraries: libraries,
          manually: true
        )
      end
    end

    def run_any_test
      # It doesn't matter what goes here, as long as it loads test_helper

      write_file 'test/example_test.rb', <<-FILE
        require 'test_helper'
      FILE

      run_n_unit_tests('test/example_test.rb')
    end

    def expect_to_say_test_framework_is_unavailable(
      result,
      test_framework_name,
      test_framework_constant
    )
      expect(result).to have_output(
        Regexp.new(
          "You're trying to configure shoulda-matchers with the " +
          ":#{test_framework_name} test framework, but the " +
          "#{test_framework_constant} constant doesn't appear to " +
          "be available"
        )
      )
    end

    def expect_to_say_library_is_unavailable(
      result,
      library_name,
      library_constant
    )
      expect(result).to have_output(
        Regexp.new(
          "You're trying to configure shoulda-matchers with the " +
          ":#{library_name} library, but the #{library_constant} constant " +
          "doesn't appear to be available"
        )
      )
    end

    context 'when Minitest is not available' do
      specify 'shoulda-matchers raises an error' do
        create_minitest_project do
          add_activemodel_to_project
        end

        result = run_any_test
        expect_to_say_test_framework_is_unavailable(
          result,
          :minitest,
          "Minitest::Test"
        )
      end
    end

    context 'when :active_model is specified but ActiveSupport::TestCase is not available' do
      specify 'shoulda-matchers raises an error' do
        create_minitest_project(libraries: [:active_model]) do
          add_activemodel_to_project

          write_file 'test/test_helper.rb', <<-CONTENT
            require 'minitest/autorun'
          CONTENT
        end

        result = run_any_test
        expect_to_say_library_is_unavailable(
          result,
          :active_model,
          "ActiveSupport::TestCase"
        )
      end
    end

    context 'when :active_model is specified but ActiveModel is not available'

    context 'when :active_record is specified but ActiveSupport::TestCase is not available'

    context 'when :active_record is specified but ActiveRecord is not available'

    context 'when :action_controller is specified but ActionController::TestCase is not available'

    context 'when :rails is specified but ActiveSupport::TestCase is not available'

    context 'when :rails is specified but ActiveModel is not available'

    context 'when :rails is specified but ActiveRecord is not available'

    context 'when :rails is specified but ActionController::TestCase is not available'
  end
end
