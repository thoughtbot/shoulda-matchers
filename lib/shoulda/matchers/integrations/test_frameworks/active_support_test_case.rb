module Shoulda
  module Matchers
    module Integrations
      module TestFrameworks
        class ActiveSupportTestCase
          Integrations.register_test_framework(self, :active_support_test_case)

          def validate!
          end

          def include(*modules)
            test_case_class.include(*modules)
          end

          def n_unit?
            true
          end

          def present?
            true
          end

          protected

          attr_reader :configuration

          private

          def test_case_class
            ActiveSupport::TestCase
          end
        end
      end
    end
  end
end
