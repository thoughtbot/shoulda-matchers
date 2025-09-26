require_relative 'gem_helpers'

module AcceptanceTests
  module RailsVersionHelpers
    include GemHelpers

    def rails_version
      bundle_version_of('rails')
    end

    def rails_7_2_x?
      rails_version =~ '~> 7.2'
    end

    def rails_gte_7_2?
      Gem::Version.new(rails_version) >= Gem::Version.new('7.2.0')
    end
  end
end
