module Shoulda
  module Matchers
    # @private
    def self.warn(msg)
      Kernel.warn "Warning from shoulda-matchers:\n\n#{msg}"
    end
  end
end
