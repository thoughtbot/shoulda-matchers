require 'shoulda/version'

if defined?(RSpec)
  require 'shoulda/integrations/rspec'
else
  require 'shoulda/integrations/test_unit'
end
