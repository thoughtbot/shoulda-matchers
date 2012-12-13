module ControllerBuilder
  TMP_VIEW_PATH = File.expand_path(File.join(TESTAPP_ROOT, 'tmp',
    'views')).freeze

  def self.included(example_group)
    example_group.class_eval do
      after do
        delete_temporary_views
        restore_original_routes
      end
    end
  end

  def define_controller(class_name, &block)
    class_name = class_name.to_s
    class_name << 'Controller' unless class_name =~ /Controller$/
    define_class(class_name, ActionController::Base, &block)
  end

  def define_routes(&block)
    Rails.application.routes.draw(&block)
    @routes = Rails.application.routes
    class << self
      include ActionDispatch::Assertions
    end
  end

  def build_response(opts = {}, &block)
    action = opts[:action] || 'example'
    partial = opts[:partial] || '_partial'
    block ||= lambda { render :nothing => true }
    controller_class = define_controller('Examples') do
      layout false
      define_method(action, &block)
    end
    controller_class.view_paths = [TMP_VIEW_PATH]

    define_routes do
      get 'examples', :to => "examples##{action}"
    end

    create_view("examples/#{action}.html.erb", 'action')
    create_view("examples/#{partial}.html.erb", 'partial')

    setup_rails_controller_test(controller_class)
    get action

    @controller
  end

  def setup_rails_controller_test(controller_class)
    @controller = controller_class.new
    @request = ::ActionController::TestRequest.new
    @response = ::ActionController::TestResponse.new

    class << self
      include ActionController::TestCase::Behavior
    end
  end

  def create_view(path, contents)
    full_path = File.join(TMP_VIEW_PATH, path)
    FileUtils.mkdir_p(File.dirname(full_path))
    File.open(full_path, 'w') { |file| file.write(contents) }
  end

  private

  def delete_temporary_views
    FileUtils.rm_rf(TMP_VIEW_PATH)
  end

  def restore_original_routes
    Rails.application.reload_routes!
  end
end

RSpec.configure do |config|
  config.include ControllerBuilder
end
