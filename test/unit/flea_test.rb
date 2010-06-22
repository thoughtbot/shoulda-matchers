require 'test_helper'

class FleaTest < ActiveSupport::TestCase
  should_have_and_belong_to_many :dogs

  context "when a flea is created" do
    setup do
      Flea.create
    end

    should have_sent_email.to('myself@me.com')
  end
end

