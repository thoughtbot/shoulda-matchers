require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  load_all_fixtures

  should_have_many :posts
  
  should_not_allow_values_for :email, "blah", "b lah"
  should_allow_values_for :email, "a@b.com", "asdf@asdf.com"
  should_ensure_length_in_range :email, 1..100
  should_ensure_value_in_range :age, 1..100
  should_protect_attributes :password
end
