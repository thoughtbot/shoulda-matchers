require_relative 'file_helpers'
require_relative 'gem_helpers'
require_relative 'minitest_helpers'

module AcceptanceTests
  module StepHelpers
    include FileHelpers
    include GemHelpers
    include MinitestHelpers

    extend RSpec::Matchers::DSL

    def create_active_model_project
      create_generic_bundler_project
      add_gem 'activemodel', active_model_version
    end

    def create_generic_bundler_project
      fs.create
      run_command! 'bundle init'
    end

    def add_shoulda_matchers_to_project(options = {})
      gem_options = { path: fs.root_directory }

      if options[:manually]
        gem_options[:require] = false
      end

      add_gem 'shoulda-matchers', gem_options

      if options[:manually]
        if options[:test_frameworks].include?(:rspec)
          append_to_file spec_helper_file_path, "require 'shoulda/matchers'"
        end

        if options[:test_frameworks].include?(:n_unit)
          append_to_file 'test/test_helper.rb', "require 'shoulda/matchers'"
        end
      end
    end

    def add_minitest_to_project
      add_gem 'minitest-reporters'

      append_to_file 'test/test_helper.rb', <<-FILE
        require 'minitest/autorun'
        require 'minitest/reporters'

        Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)
      FILE
    end

    def add_shoulda_context_to_project(options = {})
      add_gem 'shoulda-context'

      if options[:manually]
        append_to_file 'test/test_helper.rb', <<-FILE
          require 'shoulda/context'
        FILE
      end
    end

    def write_minitest_test(path)
      contents = yield minitest_test_case_superclass
      write_file(path, contents)
    end

    def run_n_unit_tests(*paths)
      run_command_within_bundle 'ruby -I lib -I test', *paths
    end

    def run_n_unit_test_suite
      run_rake_tasks('test', env: { TESTOPTS: '-v' })
    end

    def create_rails_application
      command = "bundle exec rails new #{fs.project_directory} --skip-bundle"

      run_command!(command) do |runner|
        runner.directory = nil
      end

      updating_bundle do |bundle|
        bundle.remove_gem 'turn'
        bundle.remove_gem 'coffee-rails'
        bundle.remove_gem 'uglifier'
      end
    end

    def configure_routes_with_single_wildcard_route
      write_file 'config/routes.rb', <<-FILE
        Rails.application.routes.draw do
          get ':controller(/:action(/:id(.:format)))'
        end
      FILE
    end

    def add_rspec_rails_to_project!
      add_gem 'rspec-rails', rspec_rails_version
      run_command_within_bundle!('rails g rspec:install')
      remove_from_file '.rspec', '--warnings'
    end

    def run_rspec_suite
      run_rake_tasks('spec', env: { SPEC_OPTS: '-fd' })
    end

    def add_spring_to_project
      if rails_version < 4
        add_gem 'spring'
      end

      add_gem 'spring-commands-rspec'
    end
  end
end
