require 'fileutils'

class TestApplication
  ROOT_DIR = File.expand_path('../../../tmp/aruba/testapp', __FILE__)

  def create
    clean
    generate
    within_app { install_gems }
  end

  def load
    load_environment
    run_migrations
  end

  def gemfile_path
    File.join(ROOT_DIR, 'Gemfile')
  end

  def environment_file_path
    File.join(ROOT_DIR, 'config/environment')
  end

  def temp_views_dir_path
    File.join(ROOT_DIR, 'tmp/views')
  end

  def create_temp_view(path, contents)
    full_path = temp_view_path_for(path)
    FileUtils.mkdir_p(File.dirname(full_path))
    File.open(full_path, 'w') { |file| file.write(contents) }
  end

  def delete_temp_views
    FileUtils.rm_rf(temp_views_dir_path)
  end

  def draw_routes(&block)
    Rails.application.routes.draw(&block)
    Rails.application.routes
  end

  private

  def migrations_dir_path
    File.join(ROOT_DIR, 'db/migrate')
  end

  def temp_view_path_for(path)
    File.join(temp_views_dir_path, path)
  end

  def clean
    FileUtils.rm_rf(ROOT_DIR)
  end

  def generate
    rails_new
    fix_available_locales_warning
  end

  def rails_new
    `rails new #{ROOT_DIR} --skip-bundle`
  end

  def fix_available_locales_warning
    # See here for more on this:
    # http://stackoverflow.com/questions/20361428/rails-i18n-validation-deprecation-warning

    filename = File.join(ROOT_DIR, 'config/application.rb')

    lines = File.read(filename).split("\n")
    lines.insert(-3, <<EOT)
if I18n.respond_to?(:enforce_available_locales=)
  I18n.enforce_available_locales = false
end
EOT

    File.open(filename, 'w') do |f|
      f.write(lines.join("\n"))
    end
  end

  def load_environment
    require environment_file_path
  end

  def run_migrations
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Migrator.migrate(migrations_dir_path)
  end

  def install_gems
    retrying('bundle install') do |command|
      Bundler.with_clean_env { `#{command}` }
    end
  end

  def within_app(&block)
    Dir.chdir(ROOT_DIR, &block)
  end

  def retrying(command, &runner)
    runner ||= -> { `#{command}` }

    retry_count = 0
    loop do
      output = runner.call("#{command} 2>&1")
      if $? == 0
        break
      else
        retry_count += 1
        if retry_count == 3
          raise "Command '#{command}' failed:\n#{output}"
        end
      end
    end
  end
end
