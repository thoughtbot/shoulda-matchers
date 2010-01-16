module Shoulda
  VERSION = "2.10.3"
end

if defined? Spec
  require 'shoulda/rspec'
else
  require 'shoulda/test_unit'
end
