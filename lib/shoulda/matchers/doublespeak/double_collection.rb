module Shoulda
  module Matchers
    module Doublespeak
      # @private
      class DoubleCollection
        def initialize(klass)
          @klass = klass
          @doubles_by_method_name = {}
        end

        def register_stub(method_name)
          register_double(method_name, :stub)
        end

        def register_proxy(method_name)
          register_double(method_name, :proxy)
        end

        def activate
          doubles_by_method_name.each do |method_name, double|
            double.activate
          end
        end

        def deactivate
          doubles_by_method_name.each do |method_name, double|
            double.deactivate
          end
        end

        def calls_to(method_name)
          double = doubles_by_method_name[method_name]

          if double
            double.calls
          else
            []
          end
        end

        protected

        attr_reader :klass, :doubles_by_method_name

        def register_double(method_name, implementation_type)
          implementation =
            DoubleImplementationRegistry.find(implementation_type)
          double = Double.new(klass, method_name, implementation)
          doubles_by_method_name[method_name] = double
          double
        end
      end
    end
  end
end
