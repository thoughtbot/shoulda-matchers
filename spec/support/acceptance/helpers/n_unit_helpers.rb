require_relative 'rails_version_helpers'

module AcceptanceTests
  module NUnitHelpers
    include RailsVersionHelpers

    def n_unit_test_case_superclass
      case default_test_framework
        when :test_unit then 'Test::Unit::TestCase'
        else 'Minitest::Test'
      end
    end

    def default_test_framework
      if rails_version =~ '< 4'
        :test_unit
      else
        :minitest
      end
    end
  end
end
