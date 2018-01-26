module Shoulda
  module Matchers
    module ActionController
      # The `route` matcher tests that a route resolves to a controller,
      # action, and params; and that the controller, action, and params
      # generates the same route. For an RSpec suite, this is like using a
      # combination of `route_to` and `be_routable`. In a test suite using
      # Minitest + Shoulda, it provides a more expressive syntax over
      # `assert_routing`.
      #
      # You can use this matcher either in a controller test case or in a
      # routing test case. For instance, given these routes:
      #
      #     My::Application.routes.draw do
      #       get '/posts', to: 'posts#index'
      #       get '/posts/:id', to: 'posts#show'
      #     end
      #
      # You could choose to write tests for these routes alongside other tests
      # for PostsController:
      #
      #     class PostsController < ApplicationController
      #       # ...
      #     end
      #
      #     # RSpec
      #     RSpec.describe PostsController, type: :controller do
      #       it { should route(:get, '/posts').to(action: :index) }
      #       it { should route(:get, '/posts/1').to(action: :show, id: 1) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PostsControllerTest < ActionController::TestCase
      #       should route(:get, '/posts').to(action: 'index')
      #       should route(:get, '/posts/1').to(action: :show, id: 1)
      #     end
      #
      # Or you could place the tests along with other route tests:
      #
      #     # RSpec
      #     describe 'Routing', type: :routing do
      #       it do
      #         should route(:get, '/posts').
      #           to(controller: :posts, action: :index)
      #       end
      #
      #       it do
      #         should route(:get, '/posts/1').
      #           to('posts#show', id: 1)
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class RoutesTest < ActionController::IntegrationTest
      #       should route(:get, '/posts').
      #         to(controller: :posts, action: :index)
      #
      #       should route(:get, '/posts/1').
      #         to('posts#show', id: 1)
      #     end
      #
      # Notice that in the former case, as we are inside of a test case for
      # PostsController, we do not have to specify that the routes resolve to
      # this controller. In the latter case we specify this using the
      # `controller` key passed to the `to` qualifier.
      #
      # #### Qualifiers
      #
      # ##### to
      #
      # Use `to` to specify the action (along with the controller, if needed)
      # that the route resolves to.
      #
      # `to` takes either keyword arguments (`controller` and `action`) or a
      # string that represents the controller/action pair:
      #
      #     route(:get, '/posts').to(action: index)
      #     route(:get, '/posts').to(controller: :posts, action: index)
      #     route(:get, '/posts').to('posts#index')
      #
      # If there are parameters in your route, then specify those too:
      #
      #     route(:get, '/posts/1').to('posts#show', id: 1)
      #
      # You may also specify special parameters such as `:format`:
      #
      #     route(:get, '/posts').to('posts#index', format: :json)
      #
      # ##### with_port
      #
      # Use `with_port` if the route you're testing has a constraint on it that
      # limits the route to a particular port:
      #
      #     class PortConstraint
      #       def initialize(port)
      #         @port = port
      #       end
      #
      #       def matches?(request)
      #         request.port == @port
      #       end
      #     end
      #
      #     My::Application.routes.draw do
      #       get '/posts',
      #         to: 'posts#index',
      #         constraints: PortConstraint.new(12345)
      #     end
      #
      #     # RSpec
      #     describe 'Routing', type: :routing do
      #       it do
      #         should route(:get, '/posts').
      #           to('posts#index').
      #           with_port(12345)
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class RoutesTest < ActionController::IntegrationTest
      #       should route(:get, '/posts').
      #         to('posts#index').
      #         with_port(12345)
      #     end
      #
      # @return [RouteMatcher]
      #
      def route(method, path)
        RouteMatcher.new(method, path, self)
      end

      # @private
      class RouteMatcher
        def initialize(method, path, context)
          @method = method

          @path =
            if path.start_with?('/')
              path
            else
              @path = "/#{path}"
            end

          @context = context
          @params = {}
          @port = nil
        end

        attr_reader :failure_message

        def to(*args)
          @params = RouteParams.new(args).normalize
          self
        end

        def in_context(context)
          @context = context
          self
        end

        def with_port(port)
          @path = "http://example.com:#{port}" + path
          self
        end

        def matches?(controller)
          guess_controller_if_necessary(controller)

          route_recognized?
        end

        def description
          "route #{method.to_s.upcase} #{path} to/from #{params.inspect}"
        end

        def failure_message_when_negated
          "Didn't expect to #{description}"
        end

        private

        attr_reader :method, :path, :context, :params

        def guess_controller_if_necessary(controller)
          params[:controller] ||= controller.controller_path
        end

        def route_recognized?
          context.send(
            :assert_routing,
            { method: method, path: path },
            params,
          )
          true
        rescue ::ActionController::RoutingError => error
          @failure_message = error.message
          false
        rescue Shoulda::Matchers.assertion_exception_class => error
          @failure_message = error.message
          false
        end
      end
    end
  end
end
