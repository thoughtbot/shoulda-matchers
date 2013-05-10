require 'shoulda/matchers/version'
require 'shoulda/matchers/assertion_error'
require 'shoulda/matchers/rails_shim'

if defined?(RSpec)
  require 'shoulda/matchers/integrations/rspec'
end

require 'shoulda/matchers/integrations/test_unit'
