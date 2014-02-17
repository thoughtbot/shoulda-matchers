module Shoulda
  module Matchers
    def self.warn(msg)
      Kernel.warn "Warning from shoulda-matchers:\n\n#{msg}"
    end
  end
end
