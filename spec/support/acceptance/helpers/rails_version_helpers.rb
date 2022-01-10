require_relative 'gem_helpers'

module AcceptanceTests
  module RailsVersionHelpers
    include GemHelpers

    def rails_version
      bundle_version_of('rails')
    end

    def rails_gt_6_0?
      rails_version > 6.0
    end

    def rails_6_x?
      rails_version =~ '~> 6.0'
    end
  end
end
