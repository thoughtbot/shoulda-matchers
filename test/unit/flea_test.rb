require File.dirname(__FILE__) + '/../test_helper'

class FleaTest < ActiveSupport::TestCase
  should_have_and_belong_to_many :dogs
end

