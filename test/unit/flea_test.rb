require 'test_helper'

class FleaTest < ActiveSupport::TestCase
  should_have_and_belong_to_many :dogs

  should have_sent_email.to('myself@me.com')
end

