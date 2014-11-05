require_relative 'gem_helpers'

module AcceptanceTests
  module ActiveModelHelpers
    include GemHelpers

    def active_model_version
      bundle_version_of('activemodel')
    end
  end
end
