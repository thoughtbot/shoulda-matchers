require_relative '../tests/bundle'
require_relative '../tests/command_runner'
require_relative '../tests/database'
require_relative '../tests/filesystem'

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
        install_gems
        remove_unwanted_gems
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
      write_database_configuration
    end

    def rails_new
      run_command! %W(rails new #{fs.project_directory} --skip-bundle --no-rc)
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

    def write_database_configuration
      YAML.dump(database.config.to_hash, fs.open('config/database.yml', 'w'))
    end

    def load_environment
      require environment_file_path
    end

    def run_migrations
      fs.within_project do
        run_command! 'bundle exec rake db:drop db:create db:migrate'
      end
    end

    def install_gems
      bundle.install_gems
    end

    def remove_unwanted_gems
      bundle.updating do
        bundle.remove_gem 'debugger'
        bundle.remove_gem 'byebug'
        bundle.remove_gem 'web-console'
      end
    end

    def run_command!(*args)
      Tests::CommandRunner.run!(*args)
    end
  end
end
