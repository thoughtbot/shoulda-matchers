require 'shoulda/matchers/assertion_error'
require 'shoulda/matchers/doublespeak'
require 'shoulda/matchers/error'
require 'shoulda/matchers/rails_shim'
require 'shoulda/matchers/warn'
require 'shoulda/matchers/version'

require 'shoulda/matchers/independent'

if defined?(ActiveModel)
  require 'shoulda/matchers/active_model'
end

if defined?(ActiveRecord)
  require 'shoulda/matchers/active_record'
end

if defined?(ActionController)
  require 'shoulda/matchers/action_controller'
end

if defined?(RSpec)
  require 'shoulda/matchers/integrations/rspec'
end

require 'shoulda/matchers/integrations/test_unit'
