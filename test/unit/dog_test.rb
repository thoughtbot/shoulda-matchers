require File.dirname(__FILE__) + '/../test_helper'

class DogTest < Test::Unit::TestCase
  load_all_fixtures
  should_belong_to :user
end
