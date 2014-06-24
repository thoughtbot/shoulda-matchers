module Shoulda
  module Matchers
    module Doublespeak
      # @private
      class ProxyImplementation
        extend Forwardable

        DoubleImplementationRegistry.register(self, :proxy)

        def_delegators :stub_implementation, :returns

        def self.create
          new(StubImplementation.new)
        end

        def initialize(stub_implementation)
          @stub_implementation = stub_implementation
        end

        def call(double, object, args, block)
          stub_implementation.call(double, object, args, block)
          double.call_original_method(object, args, block)
        end

        protected

        attr_reader :stub_implementation
      end
    end
  end
end
