require_relative 'file_helpers'
require_relative 'gem_helpers'
require_relative 'minitest_helpers'
require_relative 'ruby_version_helpers'

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

    def create_active_record_project
      create_generic_bundler_project
      add_gem 'activemodel',  active_model_version
      add_gem 'activerecord', active_record_version
      add_gem 'rake'

      add_gem 'sqlite3', '>=1.4'
    end

    def create_generic_bundler_project
      fs.clean
      fs.create
      run_command_isolated_from_bundle! 'bundle init'
      add_gem 'mutex_m', require: false if rails_gte_7_2?
    end

    def add_shoulda_matchers_to_project(options = {})
      AddsShouldaMatchersToProject.call(options)
    end

    def add_minitest_to_project
      append_to_file 'test/test_helper.rb', <<-FILE
        require 'minitest/autorun'
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

      run_command!(rails_new_command) do |runner|
        runner.directory = nil
      end

      updating_bundle do |bundle|
        bundle.remove_gem 'turn'
        bundle.remove_gem 'coffee-rails'
        bundle.remove_gem 'uglifier'
        bundle.remove_gem 'debugger'
        bundle.remove_gem 'byebug'
        bundle.remove_gem 'chromedriver-helper'
        bundle.remove_gem 'web-console'
      end

      add_gem 'mutex_m', require: false if rails_gte_7_2?

      fs.open('config/database.yml', 'w') do |file|
        YAML.dump(database.config.load_file, file)
      end
    end

    def rails_new_command
      if ruby_gt_4_0?
        "rails new #{fs.project_directory} --database=#{database.adapter_name} --skip-bundle --skip-javascript --no-rc --skip-bootsnap"
      else
        "bundle exec rails new #{fs.project_directory} --database=#{database.adapter_name} --skip-bundle --skip-javascript --no-rc --skip-bootsnap"
      end
    end

    def configure_routes
      write_file 'config/routes.rb', <<-FILE
        Rails.application.routes.draw do
          resources :examples, only: :index
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
      run_command_within_bundle!('bundle install')
      run_command_within_bundle!('rails g rspec:install')
      remove_from_file '.rspec', '--warnings'
    end

    def run_rspec_tests(*paths)
      run_command_within_bundle 'rspec --format documentation --backtrace', *paths
    end

    def run_rspec_suite
      run_rake_tasks('spec', env: { SPEC_OPTS: '-fd' })
    end
  end
end
