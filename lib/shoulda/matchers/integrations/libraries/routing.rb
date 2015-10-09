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
            include_into(inclusion_targets, [matchers_module], extend: true)
          end

          private

          def inclusion_target_names
            ["ActionController::TestCase"]
          end

          def matchers_module
            Shoulda::Matchers::Routing
          end
        end
      end
    end
  end
end
