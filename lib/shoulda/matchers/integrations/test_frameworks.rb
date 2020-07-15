require 'shoulda/matchers/integrations/test_frameworks/minitest_4'
require 'shoulda/matchers/integrations/test_frameworks/minitest_5'
require 'shoulda/matchers/integrations/test_frameworks/missing_test_framework'
require 'shoulda/matchers/integrations/test_frameworks/rspec'

module Shoulda
  module Matchers
    module Integrations
      # @private
      module TestFrameworks
        autoload :ActiveSupportTestCase, 'shoulda/matchers/integrations/test_frameworks/active_support_test_case'
        autoload :Minitest4, 'shoulda/matchers/integrations/test_frameworks/minitest_4'
        autoload :Minitest5, 'shoulda/matchers/integrations/test_frameworks/minitest_5'
        autoload :TestUnit, 'shoulda/matchers/integrations/test_frameworks/test_unit'
      end
    end
  end
end
