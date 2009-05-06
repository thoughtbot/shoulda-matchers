require File.dirname(__FILE__) + '/../test_helper'

class AddressTest < ActiveSupport::TestCase
  fixtures :all

  should_belong_to :addressable
  should_validate_uniqueness_of :title, :scoped_to => [:addressable_id, :addressable_type]
  should_ensure_length_at_least :zip, 5
  should_validate_numericality_of :zip
end
