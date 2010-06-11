require 'shoulda/version'

if defined? Spec
  require 'shoulda/rspec'
else
  require 'shoulda/test_unit'
end
