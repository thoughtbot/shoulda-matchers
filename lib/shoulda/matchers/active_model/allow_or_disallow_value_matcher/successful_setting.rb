module Shoulda
  module Matchers
    module ActiveModel
      class AllowOrDisallowValueMatcher
        # @private
        class SuccessfulSetting
          def successful?
            true
          end
        end
      end
    end
  end
end
