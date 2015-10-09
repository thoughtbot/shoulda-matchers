module Shoulda
  module Matchers
    module Integrations
      module TestFrameworks
        # @private
        class ActiveSupportTestCase
          Integrations.register_test_framework(self, :active_support_test_case)

          include Integrations::Inclusion

          def include(*modules, **options)
            include_into(inclusion_targets, modules)
          end

          def inclusion_target_names
            ["ActiveSupport::TestCase"]
          end

          def n_unit?
            true
          end

          def present?
            true
          end

          protected

          attr_reader :configuration
        end
      end
    end
  end
end
