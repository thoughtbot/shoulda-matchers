require_relative 'gem_helpers'

module AcceptanceTests
  module MinitestHelpers
    include GemHelpers

    def minitest_version
      bundle_version_of('minitest')
    end
  end
end
