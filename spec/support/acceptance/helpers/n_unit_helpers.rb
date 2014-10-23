require_relative 'rails_version_helpers'

module AcceptanceTests
  module NUnitHelpers
    include RailsVersionHelpers

    def default_test_framework
      if rails_version =~ '< 4'
        :test_unit
      elsif rails_version =~ '~> 4.0.0'
        :minitest_4
      else
        :minitest
      end
    end
  end
end
