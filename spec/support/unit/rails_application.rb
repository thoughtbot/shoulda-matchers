require_relative '../tests/bundle'
require_relative '../tests/command_runner'
require_relative '../tests/database'
require_relative '../tests/filesystem'
require_relative 'helpers/rails_versions'
require_relative 'helpers/ruby_versions'

require 'yaml'

module UnitTests
  class RailsApplication
    include RubyVersions

    def initialize
      @fs = Tests::Filesystem.new
      @bundle = Tests::Bundle.new
      @database = Tests::Database.instance
    end

    def create
      fs.clean
      generate

      fs.within_project do
        update_gems
      end
    end

    def load
      load_environment

      add_active_storage_migration
      add_action_text_migration

      run_migrations
    end

    def gemfile_path
      fs.find('Gemfile')
    end

    def environment_file_path
      fs.find_in_project('config/environment')
    end

    def temp_views_directory
      fs.find_in_project('tmp/views')
    end

    def create_temp_view(path, contents)
      full_path = temp_view_path_for(path)
      full_path.dirname.mkpath
      full_path.open('w') { |f| f.write(contents) }
    end

    def delete_temp_views
      if temp_views_directory.exist?
        temp_views_directory.rmtree
      end
    end

    def draw_routes(&block)
      Rails.application.routes.draw(&block)
      Rails.application.routes
    end

    protected

    attr_reader :fs, :shell, :bundle, :database

    private

    def migrations_directory
      fs.find_in_project('db/migrate')
    end

    def temp_view_path_for(path)
      temp_views_directory.join(path)
    end

    def generate
      rails_new
      fix_available_locales_warning
      write_database_configuration
      write_activerecord_model_with_default_connection
      write_activerecord_model_with_different_connection

      add_initializer_for_time_zone_aware_types
    end

    def rails_new
      run_command!(*rails_new_command)
    end

    def rails_new_command
      if ruby_gt_4_0?
        "rails new #{fs.project_directory} --database=#{database.adapter_name} --skip-bundle --skip-javascript --no-rc --skip-bootsnap"
      else
        "bundle exec rails new #{fs.project_directory} --database=#{database.adapter_name} --skip-bundle --skip-javascript --no-rc --skip-bootsnap"
      end
    end

    def fix_available_locales_warning
      # See here for more on this:
      # https://stackoverflow.com/questions/20361428/rails-i18n-validation-deprecation-warning
      fs.transform('config/application.rb') do |lines|
        lines.insert(-3, <<-EOT)
if I18n.respond_to?(:enforce_available_locales=)
  I18n.enforce_available_locales = false
end
        EOT
      end
    end

    def write_database_configuration
      fs.open('config/database.yml', 'w') do |file|
        YAML.dump(database.config.load_file, file)
      end
    end

    def write_activerecord_model_with_different_connection
      # To simulate multi-db connections, we create a new "base model" which
      # connects to a different database (in this case -
      # shoulda-matchers-test_production).
      # Any models which inherit from this class, or uses this model's
      # connection will be routed to this database.
      path = 'app/models/production_record.rb'
      fs.write(path, <<-TEXT)
class ProductionRecord < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :production
end
      TEXT
    end

    def write_activerecord_model_with_default_connection
      # Alongside ProductionRecord created above, we also create a dummy
      # DevelopmentRecord which connects to the default database (in this case -
      # shoulda-matchers-test_development, for symmetry's sake. This allows us
      # to be a little more explicit when writing tests, for example:
      #   expect(with_index_on(:age1, parent_class: DevelopmentRecord)).to have_db_index(:age1)
      #   expect(with_index_on(:age2, parent_class: ProductionRecord)).to have_db_index(:age2)
      path = 'app/models/development_record.rb'
      fs.write(path, <<-TEXT)
class DevelopmentRecord < ActiveRecord::Base
  self.abstract_class = true
end
      TEXT
    end

    def add_action_text_migration
      fs.within_project do
        if ruby_gt_4_0?
          run_command! 'rake action_text:install:migrations'
        else
          run_command! 'bundle exec rake action_text:install:migrations'
        end
      end
    end

    def add_active_storage_migration
      fs.within_project do
        if ruby_gt_4_0?
          run_command! 'rake active_storage:install:migrations'
        else
          run_command! 'bundle exec rake active_storage:install:migrations'
        end
      end
    end

    def add_initializer_for_time_zone_aware_types
      path = 'config/initializers/configure_time_zone_aware_types.rb'
      fs.write(path, <<-TEXT)
Rails.application.configure do
  config.active_record.time_zone_aware_types = [:datetime, :time]
end
      TEXT
    end

    def load_environment
      require environment_file_path
    end

    def run_migrations
      if ruby_gt_4_0?
        fs.within_project do
          run_command! 'rake db:drop:all'
          run_command! 'rake db:create RAILS_ENV=test'
          run_command! 'rake db:create RAILS_ENV=development'
          run_command! 'rake db:create RAILS_ENV=production'
        end

        fs.within_project do
          run_command! 'rake db:migrate'
        end
      else
        fs.within_project do
          run_command! 'bundle exec rake db:drop:all'
          run_command! 'bundle exec rake db:create RAILS_ENV=test'
          run_command! 'bundle exec rake db:create RAILS_ENV=development'
          run_command! 'bundle exec rake db:create RAILS_ENV=production'
        end

        fs.within_project do
          run_command! 'bundle exec rake db:migrate'
        end
      end
    end

    def update_gems
      bundle.updating do
        bundle.remove_gem 'turn'
        bundle.remove_gem 'coffee-rails'
        bundle.remove_gem 'uglifier'
        bundle.remove_gem 'debugger'
        bundle.remove_gem 'byebug'
        bundle.remove_gem 'web-console'
      end
    end

    def run_command!(*args)
      Tests::CommandRunner.run!(*args)
    end

    def rails_version
      bundle.version_of('rails')
    end
  end
end
