module Shoulda
  module Matchers
    module Integrations
      module TestFrameworks
        # @private
        class TestUnit
          Integrations.register_test_framework(self, :test_unit)

          include Integrations::Inclusion

          def include(*modules, **options)
            include_into(inclusion_targets, modules, extend: true)
          end

          def inclusion_target_names
            ["Test::Unit::TestCase"]
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
