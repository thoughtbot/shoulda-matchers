require File.join(File.dirname(__FILE__), '..', 'test_helper')
require 'mocha'

class ActiveRecordMatchersTest < Test::Unit::TestCase # :nodoc:

  context "have_attribute(attr).accepting_value" do
    should "accept a good attribute value" do
      assert_accepts have_attribute(:email).accepting_value("good@example.com"), User.new
    end

    should "reject a bad attribute value" do
      assert_rejects have_attribute(:email).accepting_value("bad"), User.new
    end

    should "accept a good attribute value and a custom message" do
      assert_accepts have_attribute(:ssn).accepting_value("xxxxxxxxx").with_message(/length/), User.new
    end

    should "reject a bad attribute value and a custom message" do
      assert_rejects have_attribute(:ssn).accepting_value("x").with_message(/length/), User.new
    end
  end

  context "accept_value(value).for" do
    should "accept a good attribute value" do
      assert_accepts accept_value("good@example.com").for(:email), User.new
    end

    should "reject a bad attribute value" do
      assert_rejects accept_value("bad").for(:email), User.new
    end

    should "accept a good attribute value and a custom message" do
      assert_accepts accept_value("xxxxxxxxx").for(:ssn).with_message(/length/), User.new
    end

    should "reject a bad attribute value and a custom message" do
      assert_rejects accept_value("x").for(:ssn).with_message(/length/), User.new
    end
  end

end
