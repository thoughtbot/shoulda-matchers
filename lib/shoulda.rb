module Shoulda
  VERSION = "2.0.6"
end

if defined? Spec
  require 'shoulda/rspec'
else
  require 'shoulda/test_unit'
end
