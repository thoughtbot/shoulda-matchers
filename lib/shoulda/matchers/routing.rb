module Shoulda
  module Matchers
    module Routing
      # @private
      def route(method, path)
        ActionController::RouteMatcher.new(method, path, self)
      end
    end
  end
end
