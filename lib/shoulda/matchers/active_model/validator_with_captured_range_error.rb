module Shoulda
  module Matchers
    module ActiveModel
      # @private
      module ValidatorWithCapturedRangeError
        def messages_description
          ' RangeError: ' + captured_range_error.message.inspect
        end
      end
    end
  end
end
