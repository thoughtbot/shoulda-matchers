module Shoulda
  module Matchers
    module Doublespeak
      MethodCall = Struct.new(:args, :block)
      MethodCallWithName = Struct.new(:method_name, :args, :block)
    end
  end
end
