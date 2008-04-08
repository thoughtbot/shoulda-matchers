require File.dirname(__FILE__) + '/../test_helper'

class DogTest < Test::Unit::TestCase
  load_all_fixtures
  should_belong_to :user
  should_have_and_belong_to_many :fleas
end
