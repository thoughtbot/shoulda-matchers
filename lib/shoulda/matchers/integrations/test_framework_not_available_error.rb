module Shoulda
  module Matchers
    module Integrations
      # @private
      class TestFrameworkNotAvailableError < Shoulda::Matchers::Error
        attr_accessor :test_framework_name, :missing_inclusion_target

        def build_message
          <<-MESSAGE
You're trying to configure shoulda-matchers with the :#{test_framework_name}
test framework, but the #{missing_inclusion_target} constant doesn't appear to
be available. Try adding this at the top of your test helper:

    require "#{require_path}"
          MESSAGE
        end

        private

        def require_path
          # No need to include other test frameworks at the moment
          # RSpec will already be loaded since it has an executable
          case missing_inclusion_target
          when /\AMini[Tt]est/
            'minitest'
          else
            raise "I don't know how to require the file for '#{missing_inclusion_target}'!"
          end
        end
      end
    end
  end
end

