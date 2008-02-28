require File.dirname(__FILE__) + '/../test_helper'

class AddressTest < Test::Unit::TestCase
  load_all_fixtures
  should_belong_to :addressable
end
