module Shoulda
  module Matchers
    module Integrations
      module TestFrameworks
        class Rspec
          Integrations.register_test_framework(self, :rspec)

          def validate!
          end

          def include(*modules)
            ::RSpec.configure do |config|
              config.include(*modules)
            end
          end

          def n_unit?
            false
          end

          def present?
            true
          end
        end
      end
    end
  end
end
