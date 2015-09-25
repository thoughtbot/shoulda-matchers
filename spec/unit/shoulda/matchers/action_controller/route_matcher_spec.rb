require 'unit_spec_helper'

describe 'Shoulda::Matchers::ActionController::RouteMatcher', type: :controller do
  shared_examples_for 'tests involving expected route parts' do |args|
    include_controller_in_expected_route_options =
      args.fetch(:include_controller_in_expected_route_options)

    context 'when all parts of the expected route match an existing route' do
      it 'accepts' do
        define_route :get, '/', action: 'index'

        assert_accepts add_target_to(
          route(:get, '/'),
          build_expected_route_options(
            include_controller_in_expected_route_options,
            action: 'index'
          )
        )
      end

      if include_controller_in_expected_route_options
        context 'and the expected controller is specified as a symbol' do
          it 'accepts' do
            define_route :get, '/', action: 'index'

            assert_accepts add_target_to(
              route(:get, '/'),
              build_expected_route_options(
                include_controller_in_expected_route_options,
                action: 'index'
              )
            )
          end
        end
      end

      context 'and the expected action is specified as a symbol' do
        it 'accepts' do
          define_route :get, '/', action: 'index'

          assert_accepts add_target_to(
            route(:get, '/'),
            build_expected_route_options(
              include_controller_in_expected_route_options,
              action: :index
            )
          )
        end
      end
    end

    context 'when no parts of the expected route match an existing route' do
      it 'rejects' do
        assert_rejects add_target_to(
          route(:get, '/non_existent_route'),
          controller: 'no_controller',
          action: 'no_action'
        )
      end
    end

    context 'when all parts of the expected route but the method match an existing route' do
      it 'rejects' do
        define_route :post, '/', action: 'index'

        assert_rejects add_target_to(
          route(:get, '/'),
          build_expected_route_options(
            include_controller_in_expected_route_options,
            action: 'index'
          )
        )
      end
    end

    context 'when all parts of the expected route but the path match an existing route' do
      it 'rejects' do
        define_route :get, '/', action: 'index'

        assert_rejects add_target_to(
          route(:get, '/different_path'),
          build_expected_route_options(
            include_controller_in_expected_route_options,
            action: 'index'
          )
        )
      end
    end

    if include_controller_in_expected_route_options
      context 'when all parts of the expected route but the controller match an existing route' do
        it 'rejects' do
          define_route :get, '/', controller: 'another_controller', action: 'index'

          assert_rejects add_target_to(
            route(:get, '/'),
            build_expected_route_options(
              include_controller_in_expected_route_options,
              action: 'index'
            )
          )
        end
      end
    end

    context 'when all parts of the expected route but the action match an existing route' do
      it 'rejects' do
        define_route :get, '/', action: 'index'

        assert_rejects add_target_to(
          route(:get, '/'),
          build_expected_route_options(
            include_controller_in_expected_route_options,
            action: 'another_action'
          )
        )
      end
    end
  end

  shared_examples_for 'tests involving params' do
    context 'when the actual route has a param' do
      context 'and the expected params include that param' do
        it 'accepts' do
          define_route :get, "/#{controller_name}/:id", action: 'show'

          assert_accepts add_target_to(
            route(:get, "/#{controller_name}/1"),
            controller: controller_name,
            action: 'show',
            id: '1'
          )
        end

        context 'but its value was not specified as a string' do
          it 'accepts, treating it as a string' do
            define_route :get, "/#{controller_name}/:id", action: 'show'

            assert_accepts add_target_to(
              route(:get, "/#{controller_name}/1"),
              controller: controller_name,
              action: 'show',
              id: 1
            )
          end
        end
      end

      context 'and the expected params do not match the actual params' do
        it 'rejects' do
          define_route :get, "/#{controller_name}/:id", action: 'show'

          params = {
            controller: controller_name,
            action: 'show',
            some: 'other',
            params: 'here'
          }
          assert_rejects add_target_to(
            route(:get, "/#{controller_name}/:id"),
            params
          )
        end
      end
    end

    context 'when the actual route has a default param whose value is a symbol' do
      context 'and the expected params include a value for it' do
        context 'as a symbol' do
          it 'accepts' do
            define_route :post, "/#{controller_name}/(.:format)",
              action: 'create',
              defaults: { format: :json }

            assert_accepts add_target_to(
              route(:post, "/#{controller_name}"),
              controller: controller_name,
              action: 'create',
              format: :json
            )
          end
        end

        context 'as a string' do
          it 'accepts' do
            define_route :post, "/#{controller_name}/(.:format)",
              action: 'create',
              defaults: { format: :json }

            assert_accepts add_target_to(
              route(:post, "/#{controller_name}"),
              controller: controller_name,
              action: 'create',
              format: 'json'
            )
          end
        end
      end
    end

    context 'when the existing route has a glob segment' do
      context 'and a param is given which represents the segment' do
        it 'accepts' do
          define_route :get, "/#{controller_name}/*id", action: 'whatever'

          assert_accepts add_target_to(
            route(:get, "/#{controller_name}/foo/bar"),
            controller: controller_name,
            action: 'whatever',
            id: 'foo/bar'
          )
        end
      end

      context 'and no param is given which represents the segment' do
        it 'rejects' do
          define_route :get, "/#{controller_name}/*id", action: 'whatever'

          assert_rejects add_target_to(
            route(:get, "/#{controller_name}"),
            controller: controller_name,
            action: 'whatever'
          )
        end
      end
    end
  end

  shared_examples_for 'core tests' do
    context 'given a controller and action specified as individual options' do
      include_examples 'tests involving expected route parts',
        include_controller_in_expected_route_options: true

      include_examples 'tests involving params'

      def add_target_to(route_matcher, params)
        route_matcher.to(params)
      end
    end

    context 'given a controller and action joined together in a string' do
      include_examples 'tests involving expected route parts',
        include_controller_in_expected_route_options: true

      include_examples 'tests involving params'

      def add_target_to(route_matcher, args)
        controller = args.fetch(:controller)
        action = args.fetch(:action)
        route_matcher.to("#{controller}##{action}", args)
      end
    end

    context 'given just an action' do
      include_examples 'tests involving expected route parts',
        include_controller_in_expected_route_options: false

      include_examples 'tests involving params'

      def add_target_to(route_matcher, params)
        route_matcher.to(params)
      end
    end
  end

  before do
    setup_rails_controller_test(controller_class)
  end

  context 'given a controller that is not namespaced' do
    include_examples 'core tests'

    def controller_class_name
      'ExamplesController'
    end
  end

  context 'given a controller that is namespaced' do
    def define_controller_under_test
      define_module('Admin')
      super
    end

    include_examples 'core tests'

    def controller_class_name
      'Admin::ExamplesController'
    end
  end

  let(:controller_class) do
    define_controller_under_test
  end

  def define_controller_under_test
    define_controller(controller_class_name)
  end

  def controller_name
    controller_class_name.sub(/Controller$/, '').underscore
  end

  def define_route(method, path, args)
    action = args.fetch(:action)
    controller = args.fetch(:controller) { controller_name }
    define_routes do
      public_send(
        method,
        path,
        args.merge(controller: controller, action: action)
      )
    end
  end

  def build_expected_route_options(include_controller_in_expected_route_options, default_options)
    default_options.dup.tap do |options|
      if include_controller_in_expected_route_options
        options[:controller] = controller_name
      end
    end
  end

  def assert_accepts(matcher)
    expect(controller).to matcher
  end

  def assert_rejects(matcher)
    expect(controller).not_to matcher
  end
end
