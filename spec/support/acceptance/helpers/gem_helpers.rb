require_relative 'base_helpers'
require_relative 'command_helpers'
require_relative 'file_helpers'

module AcceptanceTests
  module GemHelpers
    include BaseHelpers
    include CommandHelpers
    include FileHelpers

    def add_gem(gem, *args)
      bundle.add_gem(gem, *args)
    end

    def install_gems
      bundle.install_gems
    end

    def updating_bundle(&block)
      bundle.updating(&block)
    end

    def bundle_version_of(gem)
      bundle.version_of(gem)
    end

    def bundle_includes?(gem)
      bundle.includes?(gem)
    end
  end
end
