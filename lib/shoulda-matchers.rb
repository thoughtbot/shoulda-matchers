require 'shoulda/matchers/version'

if defined?(RSpec)
  require 'shoulda/matchers/integrations/rspec'
else
  require 'shoulda/matchers/integrations/test_unit'
end

