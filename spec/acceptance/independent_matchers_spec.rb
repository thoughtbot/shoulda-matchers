require 'acceptance_spec_helper'

describe 'shoulda-matchers has independent matchers' do
  context 'specifically delegate_method' do
    specify 'and integrates with a Ruby application that uses Minitest' do
      create_generic_bundler_project

      updating_bundle do
        add_minitest_to_project
        add_shoulda_context_to_project(manually: true)
        add_shoulda_matchers_to_project(
          test_frameworks: [:n_unit],
          manually: true
        )
      end

      write_file 'lib/post_office.rb', <<-FILE
        class PostOffice
        end
      FILE

      write_file 'lib/courier.rb', <<-FILE
        require 'forwardable'

        class Courier
          extend Forwardable

          def_delegators :post_office, :deliver

          attr_reader :post_office

          def initialize(post_office)
            @post_office = post_office
          end
        end
      FILE

      write_minitest_test 'test/courier_test.rb' do |test_case_superclass|
        <<-FILE
          require "test_helper"
          require "courier"
          require "post_office"

          class CourierTest < #{test_case_superclass}
            subject { Courier.new(post_office) }

            should delegate_method(:deliver).to(:post_office)

            def post_office
              PostOffice.new
            end
          end
        FILE
      end

      result = run_n_unit_tests('test/courier_test.rb')

      expect(result).to indicate_number_of_tests_was_run(1)
      expect(result).to have_output(
        'Courier should delegate #deliver to #post_office object'
      )
    end
  end
end
