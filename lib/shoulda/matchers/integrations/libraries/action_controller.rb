module Shoulda
  module Matchers
    module Integrations
      module Libraries
        # @private
        class ActionController
          Integrations.register_library(self, :action_controller)

          include Integrations::Inclusion
          include Integrations::Rails

          def integrate_with(test_framework)
            test_framework.include(matchers_module, type: :controller)

            include_into(inclusion_targets, [matchers_module], extend: true) do
              def subject
                @controller
              end
            end
          end

          def inclusion_target_names
            ["ActionController::TestCase"]
          end

          private

          def matchers_module
            Shoulda::Matchers::ActionController
          end
        end
      end
    end
  end
end
