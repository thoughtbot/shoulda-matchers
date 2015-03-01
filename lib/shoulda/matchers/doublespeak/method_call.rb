module Shoulda
  module Matchers
    module Doublespeak
      class MethodCall
        attr_reader :method_name, :args, :block, :object, :double

        def initialize(args)
          @method_name = args.fetch(:method_name)
          @args = args.fetch(:args)
          @block = args[:block]
          @double = args[:double]
          @object = args[:object]
        end

        def ==(other)
          other.is_a?(self.class) &&
            method_name == other.method_name &&
            args == other.args &&
            block == other.block &&
            double == other.double &&
            object == other.object
        end
      end
    end
  end
end
