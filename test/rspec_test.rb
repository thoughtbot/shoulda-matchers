require 'test_helper'

begin
  gem 'rspec'
  gem 'rspec-rails'
rescue LoadError => exception
  puts exception.message
  puts "RSpec integration was not tested because RSpec is not available"
else

  class RspecTest < Test::Unit::TestCase

    SHOULDA_ROOT =
      File.expand_path(File.join(File.dirname(__FILE__), '..')).freeze

    def setup
      build_gemspec
    end

    def teardown
      FileUtils.rm_rf(project_dir)
      FileUtils.rm_rf("#{shoulda_root}/pkg")
    end

    should "integrate correctly when using config.gem in test.rb" do
      create_project
      insert(rspec_dependencies, "config/environments/test.rb")
      vendor_gems('test')
      configure_spec_rails
      assert_configured
    end

    should "integrate correctly when using config.gem in environment.rb" do
      create_project
      insert(rspec_dependencies,
             "config/environment.rb",
             /Rails::Initializer\.run/)
      vendor_gems('development')
      configure_spec_rails
      assert_configured
    end

    should "integrate correctly when using require in spec_helper" do
      create_project
      configure_spec_rails
      insert(%{gem 'shoulda'; require 'shoulda'},
             "spec/spec_helper.rb",
             %{require 'spec/rails'})
      assert_configured
    end

    should "integrate correctly when unpacked and required in spec_helper" do
      create_project
      configure_spec_rails
      insert(%{require 'shoulda'},
             "spec/spec_helper.rb",
             %{require 'spec/rails'})
      unpack_gems
      assert_configured
    end

    def create_project
      command "rails #{project_dir}"
    end

    def vendor_gems(env)
      project_command "rake gems:unpack RAILS_ENV=#{env}"
    end

    def unpack_gems
      FileUtils.mkdir_p "#{project_dir}/vendor/gems"
      FileUtils.cd "#{project_dir}/vendor/gems" do
        %w(rspec rspec-rails shoulda).each do |gem|
          command "gem unpack #{gem}"
        end
      end

      insert('config.load_paths += Dir["#{RAILS_ROOT}/vendor/gems/*/lib"]',
             "config/environment.rb",
             /Rails::Initializer\.run/)
    end

    def command(command)
      output = `GEM_PATH=#{shoulda_root}/pkg #{command} 2>&1`
      unless $? == 0
        flunk("Command failed with status #{$?}\n#{command}\n#{output}")
      end
      @command_output ||= ''
      @command_output << output
      output
    end

    def project_command(command)
      result = nil
      FileUtils.cd project_dir do
        result = command(command)
      end
      result
    end

    def shoulda_command(command)
      FileUtils.cd shoulda_root do
        command(command)
      end
    end

    def project_name
      'example_rails_project'
    end

    def project_dir
      File.expand_path(File.join(File.dirname(__FILE__), project_name))
    end

    def insert(content, path, after = nil)
      path = File.join(project_dir, path)
      contents = IO.read(path)
      if after
        contents.gsub!(/^(.*#{after}.*)$/, "\\1\n#{content}")
      else
        contents << "\n" << content
      end
      File.open(path, 'w') {|file| file.write(contents) }
    end

    def rspec_dependencies
      return <<-EOS
        config.gem 'rspec',       :lib => 'spec'
        config.gem 'rspec-rails', :lib => false
        config.gem 'shoulda',     :lib => 'shoulda'
      EOS
    end

    def configure_spec_rails
      project_command "script/generate rspec"
    end

    def assert_configured
      create_model
      migrate
      create_controller
      assert_spec_passes
    end

    def create_model
      project_command "script/generate rspec_model person name:string"
      insert "validates_presence_of :name",
             "app/models/person.rb",
             /class Person/
      insert "it { should validate_presence_of(:name) }",
             "spec/models/person_spec.rb",
             /describe Person do/
    end

    def create_controller
      project_command "script/generate rspec_controller people"
      insert "def index; render :text => 'Hello'; end",
             "app/controllers/people_controller.rb",
             /class PeopleController/
      shoulda_controller_example = <<-EOS
        describe PeopleController, "on GET index" do
          integrate_views
          subject { controller }
          before(:each) { get :index }
          it { should respond_with(:success) }
        end
      EOS
      insert shoulda_controller_example,
             "spec/controllers/people_controller_spec.rb"
    end

    def migrate
      project_command "rake db:migrate"
    end

    def assert_spec_passes
      result = project_command("rake spec SPEC_OPTS=-fs")
      assert_match /should require name to be set/, result
      assert_match /should respond with 200/, result
    end

    def shoulda_root
      SHOULDA_ROOT
    end

    def build_gemspec
      backup_gemspec do
        shoulda_command "rake gemspec"
        shoulda_command "rake gem"
        shoulda_command "gem install --no-ri --no-rdoc -i pkg pkg/shoulda*.gem"
      end
    end

    def backup_gemspec
      actual = "#{shoulda_root}/shoulda.gemspec"
      backup = "#{shoulda_root}/backup.gemspec"
      FileUtils.mv(actual, backup)
      begin
        yield
      ensure
        FileUtils.mv(backup, actual)
      end
    end

  end

end
