require File.join(File.dirname(__FILE__), '..', 'test_helper')
require 'mocha'

class ActiveRecordMatchersTest < Test::Unit::TestCase # :nodoc:

  context "have_attribute matchers" do
    setup do
      @email_matcher = have_attribute(:email)
      @ssn_matcher   = have_attribute(:ssn)
    end

    should "accept a good attribute value" do
      assert_accepts @email_matcher.accepting_value("good@example.com"), User.new
    end

    should "reject a bad attribute value" do
      assert_rejects @email_matcher.accepting_value("bad"), User.new
    end

    should "accept a good attribute value and a custom message" do
      assert_accepts @ssn_matcher.accepting_value("xxxxxxxxx").with_message(/length/), User.new
    end

    should "reject a bad attribute value and a custom message" do
      assert_rejects @ssn_matcher.accepting_value("x").with_message(/length/), User.new
    end
  end

end
