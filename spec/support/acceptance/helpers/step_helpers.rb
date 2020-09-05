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
      run_command_isolated_from_bundle! 'bundle init'
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
      if rails_version =~ '~> 6.0'
        command = "bundle exec rails new #{fs.project_directory} --skip-bundle --skip-javascript --no-rc"
      else
        command = "bundle exec rails new #{fs.project_directory} --skip-bundle --no-rc"
      end

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
        bundle.add_gem 'bcrypt'
        bundle.add_gem 'pg'
      end

      fs.open('config/database.yml', 'w') do |file|
        YAML.dump(database.config.to_hash, file)
      end
    end

    def create_files_in_rails_application
      write_file 'db/migrate/1_create_users.rb', <<-FILE
        class CreateUsers < #{migration_class_name}
          def self.up
            create_table :categories_users do |t|
              t.integer :category_id
              t.integer :user_id
            end

            create_table :categories do |t|
            end

            create_table :issues do |t|
              t.integer :user_id
            end

            create_table :profiles do |t|
              t.integer :user_id
            end

            create_table :organizations do |t|
            end

            create_table :users do |t|
              t.integer  :age
              t.string   :email
              t.string   :first_name
              t.integer  :number_of_dependents
              t.string   :gender
              t.integer  :organization_id
              t.string   :password_digest
              t.string   :role
              t.integer  :status
              t.string   :social_networks
              t.string   :website_url
              t.datetime :created_at
            end

            add_index :users, :organization_id
          end
        end
      FILE

      write_file 'app/models/category.rb', <<-FILE
        class Category < ActiveRecord::Base
        end
      FILE

      write_file 'app/models/issue.rb', <<-FILE
        class Issue < ActiveRecord::Base
        end
      FILE

      write_file 'app/models/organization.rb', <<-FILE
        class Organization < ActiveRecord::Base
        end
      FILE

      write_file 'app/models/profile.rb', <<-FILE
        class Profile < ActiveRecord::Base
        end
      FILE

      write_file 'app/models/user.rb', <<-FILE
        class User < ActiveRecord::Base
          # Note: All of these validations are listed in the same order as what's
          # defined in the test (see below)

          # ActiveModel
          validates_format_of       :website_url, with: URI.regexp
          has_secure_password
          validates_absence_of      :first_name
          validates_acceptance_of   :terms_of_service
          validates_confirmation_of :email
          validates_exclusion_of    :age, in: 0..17
          validates_inclusion_of    :role, in: %w( admin manager )
          validates_length_of       :password, minimum: 10, on: :create
          validates_numericality_of :number_of_dependents, on: :create
          validates_presence_of     :email

          # ActiveRecord
          has_many                      :issues
          accepts_nested_attributes_for :issues
          belongs_to                    :organization
          enum status:                  [:active, :blocked]
          has_and_belongs_to_many       :categories
          self.implicit_order_column    = :created_at
          has_many_attached             :photos
          has_one                       :profile
          has_one_attached              :avatar
          attr_readonly                 :username
          has_rich_text                 :description
          serialize                     :social_networks
          validates                     :email, uniqueness: true
        end
      FILE

      # TODO: Controller file
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
      add_gem 'spring-commands-rspec'
    end
  end
end
