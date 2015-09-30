module Shoulda
  module Matchers
    # @private
    module Routing
      def route(method, path)
        ActionController::RouteMatcher.new(method, path, self)
      end
    end
  end
end
