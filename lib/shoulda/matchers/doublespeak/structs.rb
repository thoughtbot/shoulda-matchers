module Shoulda
  module Matchers
    module Doublespeak
      # @private
      MethodCall = Struct.new(:args, :block)
      # @private
      MethodCallWithName = Struct.new(:method_name, :args, :block)
    end
  end
end
