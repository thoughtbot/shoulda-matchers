require 'shoulda/active_record/matchers'
require 'active_support/test_case'

# :enddoc:
module ActiveSupport
  class TestCase
    include Shoulda::ActiveRecord::Matchers
  end
end
