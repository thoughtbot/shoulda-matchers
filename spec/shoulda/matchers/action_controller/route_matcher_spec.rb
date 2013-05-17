require 'spec_helper'

describe Shoulda::Matchers::ActionController::RouteMatcher, type: :controller do
  context 'given a controller with a defined glob url' do
    it 'accepts glob route' do
      controller = define_controller('Examples').new

      define_routes do
        get 'examples/*id', :to => 'examples#example'
      end

      controller.should route(:get, '/examples/foo/bar').
        to(:action => 'example', :id => 'foo/bar')
    end
  end

  context 'given a controller with a defined route' do

    it 'accepts routing the correct path to the correct parameters' do
      route_examples_to_examples.should route(:get, '/examples/1').
        to(:action => 'example', :id => '1')
    end

    it 'accepts a symbol controller' do
      route_examples_to_examples
      Object.new.should route(:get, '/examples/1').
        to(:controller => :examples, :action => 'example', :id => '1')
    end

    it 'accepts a symbol action' do
      route_examples_to_examples.should route(:get, '/examples/1').
        to(:action => :example, :id => '1')
    end

    it 'accepts a non-string parameter' do
      route_examples_to_examples.should route(:get, '/examples/1').
        to(:action => 'example', :id => 1)
    end

    it 'rejects an undefined route' do
      route_examples_to_examples.
        should_not route(:get, '/bad_route').to(:var => 'value')
    end

    it 'rejects a route for another controller' do
      route_examples_to_examples
      other = define_controller('Other').new
      other.should_not route(:get, '/examples/1').
        to(:action => 'example', :id => '1')
    end

    it 'rejects a route for different parameters' do
      route_examples_to_examples.should_not route(:get, '/examples/1').
        to(:action => 'other', :id => '1')
    end

    def route_examples_to_examples
      define_routes do
        get 'examples/:id', :to => 'examples#example'
      end

      define_controller('Examples').new
    end
  end
end
