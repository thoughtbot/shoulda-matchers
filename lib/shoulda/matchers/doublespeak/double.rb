module Shoulda
  module Matchers
    module Doublespeak
      class Double
        MethodCall = Struct.new(:args, :block)

        attr_reader :calls

        def initialize(klass, method_name, implementation)
          @klass = klass
          @method_name = method_name
          @implementation = implementation
          @installed = false
          @calls = []
        end

        def to_return(value = nil, &block)
          if block
            implementation.returns(&block)
          else
            implementation.returns(value)
          end
        end

        def install
          unless @installed
            double = self
            implementation = @implementation

            @original_method = klass.instance_method(method_name)

            klass.__send__(:define_method, method_name) do |*args, &block|
              implementation.call(double, self, args, block)
            end

            @installed = true
          end
        end

        def uninstall
          if @installed
            original_method = @original_method

            klass.__send__(:define_method, method_name) do |*args, &block|
              original_method.bind(self).call(*args, &block)
            end

            @installed = false
          end
        end

        def record_call(args, block)
          calls << MethodCall.new(args, block)
        end

        def call_original_method(object, args, block)
          if original_method
            original_method.bind(object).call(*args, &block)
          end
        end

        private

        attr_reader :klass, :method_name, :implementation, :original_method
      end
    end
  end
end
