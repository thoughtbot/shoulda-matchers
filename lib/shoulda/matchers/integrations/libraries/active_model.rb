module Shoulda
  module Matchers
    module Integrations
      module Libraries
        class ActiveModel
          Integrations.register_library(self, :active_model)

          include Integrations::Inclusion
          include Integrations::Rails

          def integrate_with(test_framework)
            test_framework.include(matchers_module)
            include_into(ActiveSupport::TestCase, matchers_module)
          end

          private

          def matchers_module
            Shoulda::Matchers::ActiveModel
          end
        end
      end
    end
  end
end
