require 'unit_spec_helper'

describe 'Shoulda::Matchers::Routing::RouteMatcher', type: :routing do
  before do
    define_controller('ThingsController')
  end

  shared_examples_for 'core tests' do
    context 'when the given method, path, controller, and action match an existing route' do
      it 'accepts' do
        define_routes { get '/', to: 'things#index' }

        assert_accepts add_target_to(
          route(:get, '/'),
          controller: 'things',
          action: 'index'
        )
      end

      context 'and the expected controller is specified as a symbol' do
        it 'accepts' do
          define_routes { get '/', to: 'things#index' }

          assert_accepts add_target_to(
            route(:get, '/'),
            controller: :things,
            action: 'index'
          )
        end
      end

      context 'and the expected action is specified as a symbol' do
        it 'accepts' do
          define_routes { get '/', to: 'things#index' }

          assert_accepts add_target_to(
            route(:get, '/'),
            controller: 'things',
            action: :index
          )
        end
      end
    end

    context 'when the given method, path, controller, and action do not match an existing route' do
      it 'rejects' do
        assert_rejects add_target_to(
          route(:get, '/non_existent_route'),
          controller: 'no_controller',
          action: 'no_action'
        )
      end
    end

    context 'when the given path, controller, and action match an existing route but the method does not' do
      it 'rejects' do
        define_routes { post '/', to: 'things#index' }

        assert_rejects add_target_to(
          route(:get, '/'),
          controller: 'things',
          action: 'index'
        )
      end
    end

    context 'when the given method, controller, and action match an existing route but the path does not' do
      it 'rejects' do
        define_routes { get '/', to: 'things#index' }

        assert_rejects add_target_to(
          route(:get, '/different_path'),
          controller: 'things',
          action: 'index'
        )
      end
    end

    context 'when the given method and path match an existing route but the controller does not' do
      it 'rejects' do
        define_routes { get '/', to: 'another_controller#index' }

        assert_rejects add_target_to(
          route(:get, '/'),
          controller: 'things',
          action: 'index'
        )
      end
    end

    context 'when the given method, path, and controller match an existing route but the action does not' do
      it 'rejects' do
        define_routes { get '/', to: 'things#index' }

        assert_rejects add_target_to(
          route(:get, '/'),
          controller: 'things',
          action: 'another_action'
        )
      end
    end

    context 'when the actual route has a param' do
      context 'and the expected params include that param' do
        it 'accepts' do
          define_routes { get '/things/:id', to: 'things#show' }

          assert_accepts add_target_to(
            route(:get, '/things/1'),
            controller: 'things',
            action: 'show',
            id: '1'
          )
        end

        context 'but its value was not specified as a string' do
          it 'accepts, treating it as a string' do
            define_routes { get '/things/:id', to: 'things#show' }

            assert_accepts add_target_to(
              route(:get, '/things/1'),
              controller: 'things',
              action: 'show',
              id: 1
            )
          end
        end
      end

      context 'and the expected params do not match the actual params' do
        it 'rejects' do
          define_routes { get '/things/:id', to: 'things#show' }

          params = {
            controller: 'things',
            action: 'show',
            some: 'other',
            params: 'here'
          }
          assert_rejects add_target_to(
            route(:get, '/things/:id'),
            params
          )
        end
      end
    end

    context 'when the actual route has a default param whose value is a symbol' do
      context 'and the expected params include a value for it' do
        context 'as a symbol' do
          it 'accepts' do
            define_routes do
              post '/things(.:format)',
                to: 'things#create',
                defaults: { format: :json }
            end

            assert_accepts add_target_to(
              route(:post, '/things'),
              controller: 'things',
              action: 'create',
              format: :json
            )
          end
        end

        context 'as a string' do
          it 'accepts' do
            define_routes do
              post '/things(.:format)',
                to: 'things#create',
                defaults: { format: :json }
            end

            assert_accepts add_target_to(
              route(:post, '/things'),
              controller: 'things',
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
          define_routes { get '/things/*id', to: 'things#whatever' }

          assert_accepts add_target_to(
            route(:get, '/things/foo/bar'),
            controller: 'things',
            action: 'whatever',
            id: 'foo/bar'
          )
        end
      end

      context 'and no param is given which represents the segment' do
        it 'rejects' do
          define_routes { get '/things/*id', to: 'things#whatever' }

          assert_rejects add_target_to(
            route(:get, '/things'),
            controller: 'things',
            action: 'whatever'
          )
        end
      end
    end
  end

  context 'given a controller and action specified as individual options' do
    include_examples 'core tests'

    def add_target_to(route_matcher, params)
      route_matcher.to(params)
    end
  end

  context 'given a controller and action joined together in a string' do
    include_examples 'core tests'

    def add_target_to(route_matcher, args)
      controller = args.fetch(:controller)
      action = args.fetch(:action)
      route_matcher.to(
        "#{controller}##{action}",
        args.except(:controller, :action)
      )
    end
  end

  def assert_accepts(matcher)
    should(matcher)
  end

  def assert_rejects(matcher)
    should_not(matcher)
  end
end
