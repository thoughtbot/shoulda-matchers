module Shoulda
  VERSION = "2.9.2"
end

if defined? Spec
  require 'shoulda/rspec'
else
  require 'shoulda/test_unit'
end
