module Shoulda
  module Matchers
    module Integrations
      module Libraries
        # @private
        class Rails
          Integrations.register_library(self, :rails)

          include Integrations::Inclusion
          include Integrations::Rails

          SUB_LIBRARIES = [
            :active_model,
            :active_record,
            :action_controller,
            :routing
          ]

          def initialize
            @sub_libraries = SUB_LIBRARIES.map do |name|
              Integrations.find_library!(name)
            end
          end

          def integrate_with(test_framework)
            Shoulda::Matchers.assertion_exception_class =
              ActiveSupport::TestCase::Assertion

            @sub_libraries.each do |library|
              library.integrate_with(test_framework)
            end
          end

          def inclusion_target_names
            sub_libraries.flat_map(&:inclusion_target_names)
          end

          protected

          attr_reader :sub_libraries
        end
      end
    end
  end
end
