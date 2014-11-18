require 'unit_spec_helper'

describe 'Shoulda::Matchers::ActionController::RouteMatcher', type: :controller do
  shared_examples_for 'a controller with a defined route' do
    context 'when controller and action are specified as explicit options' do
      it 'accepts' do
        expect(controller_with_defined_routes).
          to route(:get, "/#{controller_name}").
          to(action: 'index')
      end

      it 'accepts a symbol controller' do
        expect(controller_with_defined_routes).
          to route(:get, "/#{controller_name}").
          to(controller: controller_name.to_sym, action: 'index')
      end

      it 'accepts a symbol action' do
        expect(controller_with_defined_routes).
          to route(:get, "/#{controller_name}").
          to(action: :index)
      end

      it 'rejects an undefined route' do
        expect(controller_with_defined_routes).
          not_to route(:get, '/non_existent_route').
          to(action: 'non_existent')
      end

      it 'rejects a route for another controller' do
        define_controller_with_defined_routes
        other_controller = define_controller('Other').new
        expect(other_controller).
          not_to route(:get, "/#{controller_name}").
          to(action: 'index')
      end

      context 'when route has parameters' do
        it 'accepts a non-string parameter' do
          expect(controller_with_defined_routes).
            to route(:get, "/#{controller_name}/1").
            to(action: 'show', id: 1)
        end

        it 'rejects a route for different parameters' do
          expect(controller_with_defined_routes).
            not_to route(:get, "/#{controller_name}/1").
            to(action: 'show', some: 'other', params: 'here')
        end
      end
    end

    context 'when controller and action are specified as a joined string' do
      it 'accepts' do
        expect(controller_with_defined_routes).
          to route(:get, "/#{controller_name}").
          to("#{controller_name}#index")
      end

      context 'when route has parameters' do
        it 'accepts a non-string parameter' do
          expect(controller_with_defined_routes).
            to route(:get, "/#{controller_name}/1").
            to("#{controller_name}#show", id: 1)
        end
      end
    end

    def controller_with_defined_routes
      @_controller_with_defined_routes ||= begin
        _controller_name = controller_name

        define_routes do
          get "/#{_controller_name}", to: "#{_controller_name}#index"
          get "/#{_controller_name}/:id", to: "#{_controller_name}#show"
        end

        controller
      end
    end

    alias_method :define_controller_with_defined_routes,
      :controller_with_defined_routes
  end

  context 'given a controller with a defined glob url' do
    it 'accepts glob route' do
      controller = define_controller('Examples').new

      define_routes do
        get 'examples/*id', to: 'examples#example'
      end

      expect(controller).to route(:get, '/examples/foo/bar').
        to(action: 'example', id: 'foo/bar')
    end
  end

  context 'given a controller that is not namespaced' do
    it_behaves_like 'a controller with a defined route' do
      def controller
        define_controller(controller_name).new
      end

      def controller_name
        'examples'
      end
    end
  end

  context 'given a controller that is namespaced' do
    it_behaves_like 'a controller with a defined route' do
      def controller
        @_controller ||= begin
          define_module('Admin')
          define_controller('Admin::Examples').new
        end
      end

      def controller_name
        'admin/examples'
      end
    end
  end
end
