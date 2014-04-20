module Shoulda
  module Matchers
    module Doublespeak
      class DoubleCollection
        def initialize(klass)
          @klass = klass
          @doubles_by_method_name = {}
        end

        def stub(method_name)
          add(method_name, :stub)
        end

        def proxy(method_name)
          add(method_name, :proxy)
        end

        def install_all
          doubles_by_method_name.each do |method_name, double|
            double.install
          end
        end

        def uninstall_all
          doubles_by_method_name.each do |method_name, double|
            double.uninstall
          end
        end

        def installing_all
          install_all
          yield
        ensure
          uninstall_all
        end

        def calls_on(method_name)
          double = doubles_by_method_name[method_name]

          if double
            double.calls
          else
            []
          end
        end

        private

        attr_reader :klass, :doubles_by_method_name

        def add(method_name, implementation_type)
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
