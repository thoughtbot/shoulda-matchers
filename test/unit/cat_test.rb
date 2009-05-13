require File.dirname(__FILE__) + '/../test_helper'

class Pets::CatTest < ActiveSupport::TestCase
  should_belong_to :owner
  should_belong_to :address, :dependent => :destroy
  should_validate_presence_of :owner_id
end
