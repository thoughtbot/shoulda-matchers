require_relative 'file_helpers'
require_relative 'gem_helpers'
require_relative 'minitest_helpers'

require 'yaml'

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
      fs.clean
      fs.create
      run_command! 'bundle init'
    end

    def add_shoulda_matchers_to_project(options = {})
      AddsShouldaMatchersToProject.call(options)
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

    def write_n_unit_test(path)
      contents = yield n_unit_test_case_superclass
      write_file(path, contents)
    end

    def run_n_unit_tests(*paths)
      run_command_within_bundle 'ruby -I lib -I test', *paths
    end

    def run_n_unit_test_suite
      run_rake_tasks('test', env: { TESTOPTS: '-v' })
    end

    def create_rails_application
      fs.clean

      command = "bundle exec rails new #{fs.project_directory} --skip-bundle --no-rc"

      run_command!(command) do |runner|
        runner.directory = nil
      end

      updating_bundle do |bundle|
        bundle.remove_gem 'turn'
        bundle.remove_gem 'coffee-rails'
        bundle.remove_gem 'uglifier'
        bundle.remove_gem 'debugger'
        bundle.remove_gem 'byebug'
        bundle.remove_gem 'web-console'
        bundle.add_gem 'pg'
      end

      fs.open('config/database.yml', 'w') do |file|
        YAML.dump(database.config.to_hash, file)
      end
    end

    def configure_routes_with_single_wildcard_route
      write_file 'config/routes.rb', <<-FILE
        Rails.application.routes.draw do
          get ':controller(/:action(/:id(.:format)))'
        end
      FILE
    end

    def add_rspec_to_project
      add_gem 'rspec-core', rspec_core_version
      add_gem 'rspec-expectations', rspec_expectations_version
      append_to_file 'spec/spec_helper.rb', <<-FILE
        require 'rspec/core'
        require 'rspec/expectations'
      FILE
    end

    def add_rspec_rails_to_project!
      add_gem 'rspec-rails', rspec_rails_version
      run_command_within_bundle!('rails g rspec:install')
      remove_from_file '.rspec', '--warnings'
    end

    def run_rspec_tests(*paths)
      run_command_within_bundle 'rspec --format documentation --backtrace', *paths
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
