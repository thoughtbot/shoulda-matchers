require_relative 'gem_helpers'

module AcceptanceTests
  module RailsVersionHelpers
    include GemHelpers

    def rails_version
      bundle_version_of('rails')
    end
  end
end
