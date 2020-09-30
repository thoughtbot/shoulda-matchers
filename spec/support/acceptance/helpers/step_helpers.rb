require_relative 'file_helpers'
require_relative 'gem_helpers'
require_relative 'minitest_helpers'
require_relative '../../tests/rails_versions'

require 'rails'
require 'yaml'

module AcceptanceTests
  module StepHelpers
    include FileHelpers
    include GemHelpers
    include MinitestHelpers
    include Tests::RailsVersions

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

    def create_files_in_rails_application
      create_files_to_test_matchers_below_version_5_2

      if rails_gte_5_2?
        create_files_to_test_matchers_of_version_5_2
      end

      if rails_6_x?
        create_files_to_test_matchers_above_version_5_2
      end
    end

    def create_files_to_test_matchers_below_version_5_2
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
              t.integer :age
              t.string  :email
              t.string  :first_name
              t.integer :number_of_dependents
              t.string  :gender
              t.integer :organization_id
              t.string  :password_digest
              t.string  :role
              t.integer :status
              t.string  :social_networks
              t.string  :website_url
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
          has_one                       :profile
          attr_readonly                 :username
          serialize                     :social_networks
          validates                     :email, uniqueness: true
        end
      FILE

      # ActionController matchers
      write_file 'app/controllers/users_controller.rb', <<-FILE
        class UsersController < ApplicationController
          # Note: All of these validations are listed in the same order as what's
          # defined in the test (see below)

          def show
            @example = 'hello'
            head :ok
          end

          def create
            user_params
          end

          private
  
          def user_params
            params.require(:user).permit(
              :email,
              :password
            )
          end
        end
      FILE

      fs.transform('config/application.rb') do |lines|
        lines.insert(-3, <<-TEXT)
          config.filter_parameters << :secret_key
        TEXT
      end

      configure_routes_with_single_wildcard_route
    end

    def create_files_to_test_matchers_of_version_5_2
      run_rake_tasks!('active_storage:install:migrations')

      write_file 'db/migrate/2_create_photo_albums.rb', <<-FILE
        class CreatePhotoAlbums < #{migration_class_name}
          def self.up
            create_table :photo_albums do |t|
            end
          end
        end
      FILE

      write_file 'app/models/photo_album.rb', <<-FILE
        class PhotoAlbum < ActiveRecord::Base
          # Note: All of these validations are listed in the same order as what's
          # defined in the test (see below)

          # ActiveRecord
          has_many_attached :photos
          has_one_attached  :cover
        end
      FILE
    end

    def create_files_to_test_matchers_above_version_5_2
      run_rake_tasks!('action_text:install:migrations')

      write_file 'db/migrate/3_create_posts.rb', <<-FILE
        class CreatePosts < #{migration_class_name}
          def self.up
            create_table :posts do |t|
              t.datetime :created_at
            end
          end
        end
      FILE

      write_file 'app/models/post.rb', <<-FILE
        class Post < ActiveRecord::Base
          # Note: All of these validations are listed in the same order as what's
          # defined in the test (see below)

          # ActiveRecord
          self.implicit_order_column = :created_at
          has_rich_text                :description
        end
      FILE
    end

    def create_files_for_minitest
      create_minitest_files_to_version_below_5_2

      if rails_gte_5_2?
        create_minitest_files_to_version_5_2
      end

      if rails_6_x?
        create_minitest_files_to_version_above_5_2
      end
    end

    def create_minitest_files_to_version_below_5_2
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
          should have_one(:profile)
          should have_readonly_attribute(:username)
          should serialize(:social_networks)
          should validate_uniqueness_of(:email)
        end
      FILE

      write_file 'test/functional/users_controller_test.rb', <<-FILE
        require 'test_helper'

        class UsersControllerTest < ActionController::TestCase
          # ActionController matchers
          def setup
            get :show
          end

          should filter_param(:secret_key)
          should "(for POST #create) restrict parameters on :user to email, and password" do
            params = {
              user: {
                email: 'johndoe@example.com',
                password: 'password'
              }
            }
            matcher = permit(:email, :password).
              for(:create, params: params).
              on(:user)
            assert_accepts matcher, subject
          end

          should respond_with(:success)
        end
      FILE
    end

    def create_minitest_files_to_version_5_2
      write_file 'test/unit/photo_album_test.rb', <<-FILE
        require 'test_helper'

        class PhotoAlbumTest < ActiveSupport::TestCase
          # ActiveRecord matchers
          should have_many_attached(:photos)
          should have_one_attached(:cover)
        end
      FILE
    end

    def create_minitest_files_to_version_above_5_2
      write_file 'test/unit/post_test.rb', <<-FILE
        require 'test_helper'

        class PostTest < ActiveSupport::TestCase
          # ActiveRecord matchers
          should have_implicit_order_column(:created_at)
          should have_rich_text(:description)
        end
      FILE
    end

    def create_files_for_rspec
      create_specs_files_to_version_below_5_2

      if rails_gte_5_2?
        create_specs_files_to_version_5_2
      end

      if rails_6_x?
        create_specs_files_to_version_above_5_2
      end
    end

    def create_specs_files_to_version_below_5_2
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
          it { should have_one(:profile) }
          it { should have_readonly_attribute(:username) }
          it { should serialize(:social_networks) }
          it { should validate_uniqueness_of(:email) }
        end
      FILE

      add_rspec_file 'spec/controllers/users_controller_spec.rb', <<-FILE
        describe UsersController, "show" do
          it { should filter_param(:secret_key) }
          it do
            params = {
              user: {
                email: 'johndoe@example.com',
                password: 'password'
              }
            }
            should permit(:email, :password).
              for(:create, params: params).
              on(:user)
          end

          context '.respond_with' do
            before { get :show }
            it { should respond_with(:success) }
          end
        end
      FILE
    end

    def create_specs_files_to_version_5_2
      add_rspec_file 'spec/models/photo_album_spec.rb', <<-FILE
        describe PhotoAlbum do
          # ActiveRecord matchers
          it { should have_many_attached(:photos) }
          it { should have_one_attached(:cover) }
        end
      FILE
    end

    def create_specs_files_to_version_above_5_2
      add_rspec_file 'spec/models/post_spec.rb', <<-FILE
        describe Post do
          # ActiveRecord matchers
          it { should have_implicit_order_column(:created_at) }
          it { should have_rich_text(:description) }
        end
      FILE
    end

    def number_of_unit_tests
      if rails_6_x?
        25
      elsif rails_gte_5_2?
        # Note: It should not test:
        # - have_implicit_order_column (Rails 6+)
        # - have_rich_text             (Rails 6+)
        23
      else
        # Note: It should not test:
        # - have_implicit_order_column (Rails 6+)
        # - have_many_attached         (Rails 5.2+)
        # - have_one_attached          (Rails 5.2+)
        # - have_rich_text             (Rails 6+)
        21
      end
    end
  end
end
