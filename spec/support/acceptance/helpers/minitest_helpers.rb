module AcceptanceTests
  module MinitestHelpers
    def minitest_test_case_superclass
      if minitest_gte_5?
        'Minitest::Test'
      else
        'MiniTest::Unit::TestCase'
      end
    end

    def minitest_gte_5?
      if minitest_version
        Gem::Requirement.new('>= 5').satisfied_by?(minitest_version)
      end
    end

    def minitest_version
      Bundler.definition.specs['minitest'][0].version
    end
  end
end
