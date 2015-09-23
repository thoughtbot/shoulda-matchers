module Shoulda
  module Matchers
    module Integrations
      module TestFrameworks
        # @private
        class Minitest
          Integrations.register_test_framework(self, :minitest)

          def validate!
          end

          def include(*modules)
            test_case_class.class_eval do
              include(*modules)
              extend(*modules)
            end
          end

          def n_unit?
            true
          end

          def present?
            true
          end

          private

          def test_case_class
            Minitest::Test
          end
        end
      end
    end
  end
end
