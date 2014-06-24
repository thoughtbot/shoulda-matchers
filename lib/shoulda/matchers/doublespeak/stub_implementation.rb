module Shoulda
  module Matchers
    module Doublespeak
      # @private
      class StubImplementation
        DoubleImplementationRegistry.register(self, :stub)

        def self.create
          new
        end

        def initialize
          @implementation = proc { nil }
        end

        def returns(value = nil, &block)
          if block
            @implementation = block
          else
            @implementation = proc { value }
          end
        end

        def call(double, object, args, block)
          double.record_call(args, block)
          implementation.call(object, args, block)
        end

        protected

        attr_reader :implementation
      end
    end
  end
end
