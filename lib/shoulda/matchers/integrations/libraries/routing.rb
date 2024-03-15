module Shoulda
  module Matchers
    module Integrations
      module Libraries
        # @private
        class Routing
          Integrations.register_library(self, :routing)

          include Integrations::Inclusion
          include Integrations::Rails

          def integrate_with(test_framework)
            test_framework.include(matchers_module, type: :routing)

            tap do |instance|
              ActiveSupport.on_load(:action_controller_test_case, run_once: true) do
                instance.include_into(::ActionController::TestCase, instance.matchers_module)
              end
            end
          end

          def matchers_module
            Shoulda::Matchers::Routing
          end
        end
      end
    end
  end
end
