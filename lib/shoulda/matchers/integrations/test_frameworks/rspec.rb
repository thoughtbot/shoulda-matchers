module Shoulda
  module Matchers
    module Integrations
      module TestFrameworks
        # @private
        class Rspec
          Integrations.register_test_framework(self, :rspec)

          include Integrations::Inclusion

          def include(*modules, **options)
            RSpec.configure do |config|
              config.include(*modules, **options)
            end
          end

          # This isn't used in the method above, but we use it to ensure that
          # RSpec is available
          def inclusion_target_names
            ["RSpec"]
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
