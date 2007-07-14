require File.dirname(__FILE__) + '/../test_helper'

class TagTest < Test::Unit::TestCase
  load_all_fixtures

  should_have_many :taggings
  should_have_many :posts
end
