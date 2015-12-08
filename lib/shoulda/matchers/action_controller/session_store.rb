module Shoulda
  module Matchers
    module ActionController
      # @private
      class SessionStore < Store
        def name
          'session'
        end

        def store
          controller.session
        end
      end
    end
  end
end
