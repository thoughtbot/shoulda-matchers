require 'shoulda/matchers/configuration'
require 'shoulda/matchers/doublespeak'
require 'shoulda/matchers/error'
require 'shoulda/matchers/independent'
require 'shoulda/matchers/integrations'
require 'shoulda/matchers/matcher_collection'
require 'shoulda/matchers/matcher_context'
require 'shoulda/matchers/rails_shim'
require 'shoulda/matchers/util'
require 'shoulda/matchers/version'
require 'shoulda/matchers/warn'

require 'shoulda/matchers/action_controller'
require 'shoulda/matchers/active_model'
require 'shoulda/matchers/active_record'
require 'shoulda/matchers/routing'

module Shoulda # :nodoc:
  module Matchers # :nodoc:
    class << self
      # @private
      attr_writer :assertion_exception_class

      # @private
      #
      # Normally set during integration (see
      # Shoulda::Matchers::Integrations::Libraries::Rails#integrate_with),
      # but several matchers (route, redirect_to, render_template) rescue
      # this class around Rails' own assert_* helpers, which always raise
      # via Minitest under the hood regardless of whether the outer test
      # suite is driven by Minitest or RSpec. Fall back to
      # ::Minitest::Assertion - the same value integration sets it to via
      # ActiveSupport::TestCase::Assertion, which is that same class - so
      # those matchers don't raise `TypeError: class or module required
      # for rescue clause` if a matcher runs before integration has set
      # this (or in a setup where it never does).
      def assertion_exception_class
        @assertion_exception_class || ::Minitest::Assertion
      end
    end
  end
end
