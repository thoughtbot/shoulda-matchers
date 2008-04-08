require File.dirname(__FILE__) + '/../test_helper'

class FleaTest < Test::Unit::TestCase
  load_all_fixtures
  should_have_and_belong_to_many :dogs
end

