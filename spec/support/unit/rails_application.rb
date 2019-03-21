require_relative '../tests/bundle'
require_relative '../tests/command_runner'
require_relative '../tests/database'
require_relative '../tests/filesystem'
require_relative 'helpers/rails_versions'

require 'yaml'

module UnitTests
  class RailsApplication
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
      remove_bootsnap
      write_database_configuration

      if rails_version >= 5
        add_initializer_for_time_zone_aware_types
      end
    end

    def rails_new
      run_command!(*rails_new_command)
    end

    def rails_new_command
      if rails_version > 5
        [
          'rails',
          'new',
          fs.project_directory.to_s,
          '--skip-bundle',
          '--no-rc',
          '--skip-webpack-install',
        ]
      else
        [
          'rails',
          'new',
          fs.project_directory.to_s,
          '--skip-bundle',
          '--no-rc',
        ]
      end
    end

    def fix_available_locales_warning
      # See here for more on this:
      # http://stackoverflow.com/questions/20361428/rails-i18n-validation-deprecation-warning
      fs.transform('config/application.rb') do |lines|
        lines.insert(-3, <<-EOT)
if I18n.respond_to?(:enforce_available_locales=)
  I18n.enforce_available_locales = false
end
        EOT
      end
    end

    def remove_bootsnap
      # Rails 5.2 introduced bootsnap, which is helpful when you're developing
      # or deploying an app, but we don't really need it (and it messes with
      # Zeus anyhow)
      fs.comment_lines_matching(
        'config/boot.rb',
        %r{\Arequire 'bootsnap/setup'},
      )
    end

    def write_database_configuration
      YAML.dump(database.config.to_hash, fs.open('config/database.yml', 'w'))
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
      fs.within_project do
        run_command! 'bundle exec rake db:drop db:create db:migrate'
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
        bundle.add_gem 'pg'
        bundle.remove_gem 'sqlite3'
        bundle.add_gem 'sqlite3', '~> 1.3.6'
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
