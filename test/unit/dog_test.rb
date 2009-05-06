require File.dirname(__FILE__) + '/../test_helper'

class Pets::DogTest < ActiveSupport::TestCase
  should_belong_to :user
  should_belong_to :address, :dependent => :destroy
  should_have_many :treats
  should_have_and_belong_to_many :fleas
  should_validate_presence_of :owner_id, :treats, :fleas
end
