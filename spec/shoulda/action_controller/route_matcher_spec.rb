require 'spec_helper'

describe Shoulda::Matchers::ActionController::RouteMatcher do
  context "given a controller with a defined glob url" do
    let(:controller) { define_controller('Examples').new }

    before do
      define_routes do
        match 'examples/*id', :to => 'examples#example'
      end
    end

    it "should accept glob route" do
      controller.should route(:get, '/examples/foo/bar').
        to(:action => 'example', :id => 'foo/bar')
    end
  end

  context "given a controller with a defined route" do
    let!(:controller) { define_controller('Examples').new }

    before do
      define_routes do
        match 'examples/:id', :to => 'examples#example'
      end
    end

    it "should accept routing the correct path to the correct parameters" do
      controller.should route(:get, '/examples/1').
        to(:action => 'example', :id => '1')
    end

    it "should accept a symbol controller" do
      Object.new.should route(:get, '/examples/1').
        to(:controller => :examples,
           :action     => 'example',
           :id         => '1')
    end

    it "should accept a symbol action" do
      controller.should route(:get, '/examples/1').
        to(:action => :example, :id => '1')
    end

    it "should accept a non-string parameter" do
      controller.should route(:get, '/examples/1').
        to(:action => 'example', :id => 1)
    end

    it "should reject an undefined route" do
      controller.should_not route(:get, '/bad_route').to(:var => 'value')
    end

    it "should reject a route for another controller" do
      other = define_controller('Other').new
      other.should_not route(:get, '/examples/1').
        to(:action => 'example', :id => '1')
    end

    it "should reject a route for different parameters" do
      controller.should_not route(:get, '/examples/1').
        to(:action => 'other', :id => '1')
    end
  end
end
