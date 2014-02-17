require 'shoulda/matchers/assertion_error'
require 'shoulda/matchers/error'
require 'shoulda/matchers/rails_shim'
require 'shoulda/matchers/warn'
require 'shoulda/matchers/version'

if defined?(RSpec)
  require 'shoulda/matchers/integrations/rspec'
end

require 'shoulda/matchers/integrations/test_unit'
