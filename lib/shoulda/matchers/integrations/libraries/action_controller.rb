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

            tap do |instance|
              ActiveSupport.on_load(:action_controller_test_case, run_once: true) do
                instance.include_into(::ActionController::TestCase, instance.matchers_module) do
                  def subject # rubocop:disable Lint/NestedMethodDefinition
                    @controller
                  end
                end
              end
            end
          end

          def matchers_module
            Shoulda::Matchers::ActionController
          end
        end
      end
    end
  end
end
