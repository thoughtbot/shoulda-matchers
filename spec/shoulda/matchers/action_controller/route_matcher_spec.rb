require 'spec_helper'

describe Shoulda::Matchers::ActionController::RouteMatcher, type: :controller do
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

  context 'given a controller with a defined route' do

    it 'accepts routing the correct path to the correct parameters' do
      expect(route_examples_to_examples).to route(:get, '/examples/1').
        to(action: 'example', id: '1')
    end

    it 'accepts a symbol controller' do
      route_examples_to_examples
      expect(Object.new).to route(:get, '/examples/1').
        to(controller: :examples, action: 'example', id: '1')
    end

    it 'accepts a symbol action' do
      expect(route_examples_to_examples).to route(:get, '/examples/1').
        to(action: :example, id: '1')
    end

    it 'accepts a non-string parameter' do
      expect(route_examples_to_examples).to route(:get, '/examples/1').
        to(action: 'example', id: 1)
    end

    it 'rejects an undefined route' do
      expect(route_examples_to_examples).
        not_to route(:get, '/bad_route').to(var: 'value')
    end

    it 'rejects a route for another controller' do
      route_examples_to_examples
      other = define_controller('Other').new
      expect(other).not_to route(:get, '/examples/1').
        to(action: 'example', id: '1')
    end

    it 'rejects a route for different parameters' do
      expect(route_examples_to_examples).not_to route(:get, '/examples/1').
        to(action: 'other', id: '1')
    end

    it "accepts a string as first parameter" do
      expect(route_examples_to_examples).to route(:get, '/examples/1').
        to("examples#example", id: '1')
    end

    def route_examples_to_examples
      define_routes do
        get 'examples/:id', to: 'examples#example'
      end

      define_controller('Examples').new
    end
  end
end
