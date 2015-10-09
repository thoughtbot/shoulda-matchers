module Shoulda
  module Matchers
    module Integrations
      module TestFrameworks
        # @private
        class Minitest5
          Integrations.register_test_framework(self, :minitest_5)
          Integrations.register_test_framework(self, :minitest)

          include Integrations::Inclusion

          def include(*modules, **options)
            include_into(inclusion_targets, modules, extend: true)
          end

          def inclusion_target_names
            ["Minitest::Test"]
          end

          def n_unit?
            true
          end

          def present?
            true
          end
        end
      end
    end
  end
end
