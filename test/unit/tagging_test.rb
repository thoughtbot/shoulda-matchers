require File.dirname(__FILE__) + '/../test_helper'

class TaggingTest < Test::Unit::TestCase
  load_all_fixtures

  should_belong_to :post
  should_belong_to :tag
end
