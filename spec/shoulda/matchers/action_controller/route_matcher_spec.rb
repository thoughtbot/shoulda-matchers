require "spec_helper"

describe Shoulda::Matchers::ActionController::RouteMatcher do
  context "given a controller with a defined glob url" do
    it "accepts glob route" do
      controller = define_controller("Examples").new

      define_routes do
        match "examples/*id", :to => "examples#example"
      end

      controller.should route(:get, "/examples/foo/bar").
        to(:action => "example", :id => "foo/bar")
    end
  end

  context "given a controller with a defined route" do
    let!(:controller) { define_controller("Examples").new }

    before do
      define_routes do
        match "examples/:id", :to => "examples#example"
      end
    end

    it "accepts routing the correct path to the correct parameters" do
      controller.should route(:get, "/examples/1").
        to(:action => "example", :id => "1")
    end

    it "accepts a symbol controller" do
      Object.new.should route(:get, "/examples/1").
        to(:controller => :examples,
           :action     => "example",
           :id         => "1")
    end

    it "accepts a symbol action" do
      controller.should route(:get, "/examples/1").
        to(:action => :example, :id => "1")
    end

    it "accepts a non-string parameter" do
      controller.should route(:get, "/examples/1").
        to(:action => "example", :id => 1)
    end

    it "rejects an undefined route" do
      controller.should_not route(:get, "/bad_route").to(:var => "value")
    end

    it "rejects a route for another controller" do
      other = define_controller("Other").new
      other.should_not route(:get, "/examples/1").
        to(:action => "example", :id => "1")
    end

    it "rejects a route for different parameters" do
      controller.should_not route(:get, "/examples/1").
        to(:action => "other", :id => "1")
    end
  end
end
