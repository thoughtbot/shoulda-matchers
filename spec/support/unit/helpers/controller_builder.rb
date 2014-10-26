module ControllerBuilder
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
    @routes = $test_app.draw_routes(&block)
    class << self
      include ActionDispatch::Assertions
    end
  end

  def build_fake_response(opts = {}, &block)
    action = opts[:action] || 'example'
    partial = opts[:partial] || '_partial'
    block ||= lambda { render nothing: true }
    controller_class = define_controller('Examples') do
      layout false
      define_method(action, &block)
    end
    controller_class.view_paths = [ $test_app.temp_views_dir_path ]

    define_routes do
      get 'examples', to: "examples##{action}"
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
    $test_app.create_temp_view(path, contents)
  end

  def controller_for_resource_with_strong_parameters(options = {}, &action_body)
    model_name = options.fetch(:model_name, 'User')
    controller_name = options.fetch(:controller_name, 'UsersController')
    collection_name = controller_name.
      to_s.sub(/Controller$/, '').underscore.
      to_sym
    action_name = options.fetch(:action, :some_action)
    routes ||= options.fetch(:routes, -> { resources collection_name })

    define_model(model_name)

    controller_class = define_controller(controller_name) do
      define_method action_name do
        if action_body
          instance_eval(&action_body)
        end

        render nothing: true
      end
    end

    setup_rails_controller_test(controller_class)

    define_routes(&routes)

    controller_class
  end

  private

  def delete_temporary_views
    $test_app.delete_temp_views
  end

  def restore_original_routes
    Rails.application.reload_routes!
  end
end

RSpec.configure do |config|
  config.include ControllerBuilder
end
