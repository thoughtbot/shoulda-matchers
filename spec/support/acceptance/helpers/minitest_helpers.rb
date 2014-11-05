require_relative 'gem_helpers'

module AcceptanceTests
  module MinitestHelpers
    include GemHelpers

    def minitest_test_case_superclass
      if minitest_version >= 5
        'Minitest::Test'
      else
        'MiniTest::Unit::TestCase'
      end
    end

    def minitest_version
      bundle_version_of('minitest')
    end
  end
end
