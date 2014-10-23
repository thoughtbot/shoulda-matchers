module Shoulda
  module Matchers
    module Integrations
      module TestFrameworks
        class Minitest4
          Integrations.register_test_framework(self, :minitest_4)

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
            MiniTest::Unit::TestCase
          end
        end
      end
    end
  end
end
