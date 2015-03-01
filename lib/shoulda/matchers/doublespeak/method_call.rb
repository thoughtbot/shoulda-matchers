module Shoulda
  module Matchers
    module Doublespeak
      class MethodCall
        attr_accessor :return_value
        attr_reader :method_name, :args, :block, :object, :double

        def initialize(args)
          @method_name = args.fetch(:method_name)
          @args = args.fetch(:args)
          @block = args[:block]
          @double = args[:double]
          @object = args[:object]
          @return_value = nil
        end

        def with_return_value(return_value)
          dup.tap do |call|
            call.return_value = return_value
          end
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
