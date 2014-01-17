require 'spec_helper'

describe Shoulda::Matchers::ActionController::RouteParams do
  describe "#normalize" do
    context "when the route parameters is a hash" do
      it "stringifies the values in the hash" do
        expect(build_route_params(controller: :examples, action: 'example', id: '1').normalize).
          to eq({ controller: "examples", action: "example", id: "1" })
      end
    end

    context "when the route parameters is a string and a hash" do
      it "produces a hash of route parameters" do
        expect(build_route_params("examples#example", id: '1').normalize).
          to eq({ controller: "examples", action: "example", id: "1" })
      end
    end

    context "when the route params is a string" do
      it "produces a hash of route params" do
        expect(build_route_params("examples#index").normalize).
          to eq({ controller: "examples", action: "index"})
      end
    end
  end

  def build_route_params(*params)
    Shoulda::Matchers::ActionController::RouteParams.new(params)
  end
end
