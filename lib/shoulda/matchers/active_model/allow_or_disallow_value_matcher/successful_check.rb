module Shoulda
  module Matchers
    module ActiveModel
      class AllowOrDisallowValueMatcher
        # @private
        class SuccessfulCheck
          def successful?
            true
          end
        end
      end
    end
  end
end
