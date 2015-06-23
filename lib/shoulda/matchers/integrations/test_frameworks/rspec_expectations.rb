module Shoulda
  module Matchers
    module Integrations
      module TestFrameworks
        # @private
        class RspecExpectations
          Integrations.register_test_framework(self, :rspec_exp)

          def validate!
            return if defined? RSpec::Matchers
            raise TestFrameworkNotFound, <<-EOT
You need to include the 'rspec-expectations' gem to Gemfile, and add
the line before requiring the shoulda matchers:

require 'rspec/expectations'
EOT
          end

          def include(*modules, **_options)
            RSpec::Matchers.send(:include, *modules)
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
