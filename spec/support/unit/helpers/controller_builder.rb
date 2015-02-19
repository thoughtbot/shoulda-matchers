module UnitTests
  module ControllerBuilder
    def self.configure_example_group(example_group)
      example_group.include(self)

      example_group.after do
        delete_temporary_views
        restore_original_routes
      end
    end

    def define_controller(class_name, &block)
      class_name = class_name.to_s
      class_name << 'Controller' unless class_name =~ /Controller$/
      define_class(class_name, ActionController::Base, &block)
    end

    def define_routes(&block)
      self.routes = $test_app.draw_routes(&block)
    end

    def build_fake_response(opts = {}, &block)
      action = opts[:action] || 'example'
      partial = opts[:partial] || '_partial'
      block ||= lambda { render nothing: true }
      controller_class = define_controller('Examples') do
        layout false
        define_method(action, &block)
      end
      controller_class.view_paths = [ $test_app.temp_views_directory.to_s ]

      define_routes do
        get 'examples', to: "examples##{action}"
      end

      create_view("examples/#{action}.html.erb", 'action')
      create_view("examples/#{partial}.html.erb", 'partial')

      setup_rails_controller_test(controller_class)
      self.class.render_views(true)

      get action

      controller
    end

    def setup_rails_controller_test(controller_class)
      @controller = controller_class.new
    end

    def create_view(path, contents)
      $test_app.create_temp_view(path, contents)
    end

    def delete_temporary_views
      $test_app.delete_temp_views
    end

    def restore_original_routes
      Rails.application.reload_routes!
    end
  end
end
