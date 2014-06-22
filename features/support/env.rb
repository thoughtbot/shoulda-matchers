require 'aruba/cucumber'
require 'pry'

Before do
  @aruba_timeout_seconds = 60 * 2
end
