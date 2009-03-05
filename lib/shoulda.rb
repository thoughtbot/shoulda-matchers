module Shoulda
  VERSION = "2.10.1"
end

if defined? Spec
  require 'shoulda/rspec'
else
  require 'shoulda/test_unit'
end
