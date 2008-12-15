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

  context "belong_to" do
    should "accept a good association with the default foreign key" do
      assert_accepts belong_to(:address), Dog.new
    end

    should "reject a nonexistent association" do
      assert_rejects belong_to(:tag), Dog.new
    end

    should "reject an association of the wrong type" do
      assert_rejects belong_to(:address), User.new
    end

    should "reject an association that has a nonexistent foreign key" do
      assert_rejects belong_to(:atlantis), User.new
    end

    should "accept an association with an existing custom foreign key" do
      assert_accepts belong_to(:user), Dog.new
    end

    should "accept a polymorphic association" do
      assert_accepts belong_to(:addressable), Address.new
    end
  end

  context "have_many" do
    should "accept a valid association without any options" do
      assert_accepts have_many(:dogs), User.new
    end

    should "accept a valid association with a :through option" do
      assert_accepts have_many(:friends), User.new
    end

    should "accept a valid association with an :as option" do
      assert_accepts have_many(:addresses), User.new
    end

    should "reject an association that has a nonexistent foreign key" do
      assert_rejects have_many(:fleas), User.new
    end

    should "reject an association with a bad :as option" do
      assert_rejects have_many(:addresses), Dog.new
    end

    should "reject an association that has a bad :through option" do
      assert_rejects have_many(:enemies).through(:friends), User.new
    end

    should "reject an association that has the wrong :through option" do
      assert_rejects have_many(:friends).through(:dogs), User.new
    end

    should "accept an association with a valid :dependent option" do
      assert_accepts have_many(:posts).dependent(:destroy), User.new
    end

    should "reject an association with a bad :dependent option" do
      assert_rejects have_many(:dogs).dependent(:destroy), User.new
    end
  end

  context "has_one" do
    should "accept a valid association without any options" do
      assert_accepts have_one(:friendship), User.new
    end

    should "accept a valid association with an :as option" do
      assert_accepts have_one(:address), User.new
    end

    should "reject an association that has a nonexistent foreign key" do
      assert_rejects have_one(:flea), User.new
    end

    should "reject an association with a bad :as option" do
      assert_rejects have_one(:address), Flea.new
    end

    should "accept an association with a valid :dependent option" do
      assert_accepts have_one(:friendship).dependent(:destroy), User.new
    end

    should "reject an association with a bad :dependent option" do
      assert_rejects have_one(:friendship).dependent(:bad), User.new
    end
  end

end
