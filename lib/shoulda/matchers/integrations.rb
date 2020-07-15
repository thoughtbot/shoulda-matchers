module Shoulda
  module Matchers
    # @private
    module Integrations
      autoload :Configuration, 'shoulda/matchers/integrations/configuration'
      autoload :ConfigurationError, 'shoulda/matchers/integrations/configuration_error'
      autoload :Inclusion, 'shoulda/matchers/integrations/inclusion'
      autoload :Rails, 'shoulda/matchers/integrations/rails'
      autoload :Registry, 'shoulda/matchers/integrations/registry'

      class << self
        def register_library(klass, name)
          library_registry.register(klass, name)
        end

        def find_library!(name)
          library_registry.find!(name)
        end

        def register_test_framework(klass, name)
          test_framework_registry.register(klass, name)
        end

        def find_test_framework!(name)
          test_framework_registry.find!(name)
        end

        private

        def library_registry
          @_library_registry ||= Registry.new
        end

        def test_framework_registry
          @_test_framework_registry ||= Registry.new
        end
      end
    end
  end
end

require 'shoulda/matchers/integrations/libraries'
require 'shoulda/matchers/integrations/test_frameworks'
