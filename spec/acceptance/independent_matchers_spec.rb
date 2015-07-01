require 'acceptance_spec_helper'

describe 'shoulda-matchers has independent matchers, specifically delegate_method' do
  specify 'and integrates with a Ruby application that uses the default test framework' do
    create_generic_bundler_project

    updating_bundle do
      add_minitest_to_project
      add_shoulda_context_to_project(manually: true)
      add_shoulda_matchers_to_project(
        test_frameworks: [default_test_framework],
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

    write_n_unit_test 'test/courier_test.rb' do |test_case_superclass|
      <<-FILE
        require 'test_helper'
        require 'courier'
        require 'post_office'

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

  specify 'and integrates with a Ruby application that uses RSpec' do
    create_generic_bundler_project

    updating_bundle do
      add_rspec_to_project
      add_shoulda_matchers_to_project(
        manually: true,
        with_configuration: false
      )
      write_file 'spec/spec_helper.rb', <<-FILE
        require 'shoulda/matchers/independent'

        RSpec.configure do |config|
          config.include(Shoulda::Matchers::Independent)
        end
      FILE
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

    write_file 'spec/courier_spec.rb', <<-FILE
      require 'spec_helper'
      require 'courier'
      require 'post_office'

      describe Courier do
        subject { Courier.new(post_office) }

        it { should delegate_method(:deliver).to(:post_office) }

        def post_office
          PostOffice.new
        end
      end
    FILE

    result = run_rspec_tests('spec/courier_spec.rb')

    expect(result).to indicate_number_of_tests_was_run(1)
    expect(result).to have_output(
      /Courier\s+should delegate #deliver to #post_office object/
    )
  end
end
