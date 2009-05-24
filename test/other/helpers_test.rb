require File.join(File.dirname(__FILE__), '..', 'test_helper')
require 'action_mailer'
require 'mocha'

class HelpersTest < ActiveSupport::TestCase # :nodoc:

  context "given delivered emails" do
    setup do
      email1 = stub(:subject => "one", :to => ["none1@email.com"])
      email2 = stub(:subject => "two", :to => ["none2@email.com"])
      ActionMailer::Base.stubs(:deliveries).returns([email1, email2])
    end

    should "have sent an email" do
      assert_sent_email

      assert_raises(Test::Unit::AssertionFailedError) do
        assert_did_not_send_email
      end
    end

    should "find email one" do
      assert_sent_email do |e|
        e.subject =~ /one/
      end
    end

    should "not find an email that doesn't exist" do
      assert_raises(Test::Unit::AssertionFailedError) do
        assert_sent_email do |e|
          e.subject =~ /whatever/
        end
      end
    end
  end

  context "when there are no emails" do
    setup do
      ActionMailer::Base.stubs(:deliveries).returns([])
    end

    should "not have sent an email" do
      assert_did_not_send_email

      assert_raises(Test::Unit::AssertionFailedError) do
        assert_sent_email
      end
    end
  end

  context "an array of values" do
    setup do
      @a = ['abc', 'def', 3]
    end

    [/b/, 'abc', 3].each do |x|
      should "contain #{x.inspect}" do
        assert_raises(Test::Unit::AssertionFailedError) do
          assert_does_not_contain @a, x
        end
        assert_contains @a, x
      end
    end

    should "not contain 'wtf'" do
      assert_raises(Test::Unit::AssertionFailedError) {assert_contains @a, 'wtf'}
      assert_does_not_contain @a, 'wtf'
    end

    should "be the same as another array, ordered differently" do
      assert_same_elements(@a, [3, "def", "abc"])
      assert_raises(Test::Unit::AssertionFailedError) do
        assert_same_elements(@a, [3, 3, "def", "abc"])
      end
      assert_raises(Test::Unit::AssertionFailedError) do
        assert_same_elements([@a, "abc"].flatten, [3, 3, "def", "abc"])
      end
    end
  end

  context "an array of values" do
    setup do
      @a = [1, 2, "(3)"]
    end

    context "after adding another value" do
      setup do
        @a.push(4)
      end

      should_change("the number of elements", :by => 1) { @a.length }
      should_change("the number of elements", :from => 3) { @a.length }
      should_change("the number of elements", :to => 4) { @a.length }
      should_change("the first element", :by => 0) { @a[0] }
      should_not_change("the first element") { @a[0] }

      # tests for deprecated behavior
      should_change "@a.length", :by => 1
      should_change "@a.length", :from => 3
      should_change "@a.length", :to => 4
      should_change "@a[0]", :by => 0
      should_not_change "@a[0]"
    end

    context "after replacing it with an array of strings" do
      setup do
        @a = %w(a b c d e f)
      end

      should_change("the number of elements", :by => 3) { @a.length }
      should_change("the number of elements", :from => 3, :to => 6, :by => 3) { @a.length }
      should_change("the first element") { @a[0] }
      should_change("the second element", :from => 2, :to => "b") { @a[1] }
      should_change("the third element", :from => /\d/, :to => /\w/) { @a[2] }
      should_change("the last element", :to => String) { @a[3] }

      # tests for deprecated behavior
      should_change "@a.length", :by => 3
      should_change "@a.length", :from => 3, :to => 6, :by => 3
      should_change "@a[0]"
      should_change "@a[1]", :from => 2, :to => "b"
      should_change "@a[2]", :from => /\d/, :to => /\w/
      should_change "@a[3]", :to => String
    end
  end

  context "assert_good_value" do
    should "validate a good email address" do
      assert_good_value User.new, :email, "good@example.com"
    end

    should "validate a good SSN with a custom message" do
      assert_good_value User.new, :ssn, "xxxxxxxxx", /length/
    end

    should "fail to validate a bad email address" do
      assert_raises Test::Unit::AssertionFailedError do
        assert_good_value User.new, :email, "bad"
      end
    end

    should "fail to validate a bad SSN that is too short" do
      assert_raises Test::Unit::AssertionFailedError do
        assert_good_value User.new, :ssn, "x", /length/
      end
    end

    should "accept a class as the first argument" do
      assert_good_value User, :email, "good@example.com"
    end

    context "with an instance variable" do
      setup do
        @product = Product.new(:tangible => true)
      end

      should "use that instance variable" do
        assert_good_value Product, :price, "9999", /included/
      end
    end
  end

  context "assert_bad_value" do
    should "invalidate a bad email address" do
      assert_bad_value User.new, :email, "bad"
    end

    should "invalidate a bad SSN with a custom message" do
      assert_bad_value User.new, :ssn, "x", /length/
    end

    should "fail to invalidate a good email address" do
      assert_raises Test::Unit::AssertionFailedError do
        assert_bad_value User.new, :email, "good@example.com"
      end
    end

    should "fail to invalidate a good SSN" do
      assert_raises Test::Unit::AssertionFailedError do
        assert_bad_value User.new, :ssn, "xxxxxxxxx", /length/
      end
    end

    should "accept a class as the first argument" do
      assert_bad_value User, :email, "bad"
    end

    context "with an instance variable" do
      setup do
        @product = Product.new(:tangible => true)
      end

      should "use that instance variable" do
        assert_bad_value Product, :price, "0", /included/
      end
    end
  end

  context "a matching matcher" do
    setup do
      @matcher = stub('matcher', :matches?                 => true,
                                 :failure_message          => 'bad failure message',
                                 :negative_failure_message => 'big time failure')
    end

    should "pass when given to assert_accepts with no message expectation" do
      assert_accepts @matcher, 'target'
    end

    should "pass when given to assert_accepts with a matching message" do
      assert_accepts @matcher, 'target', :message => /big time/
    end

    should "fail when given to assert_accepts with non-matching message" do
      assert_raise Test::Unit::AssertionFailedError do
        assert_accepts @matcher, 'target', :message => /small time/
      end
    end

    context "when given to assert_rejects" do
      setup do
        begin
          assert_rejects @matcher, 'target'
        rescue Test::Unit::AssertionFailedError => @error
        end
      end

      should "fail" do
        assert_not_nil @error
      end

      should "use the error message from the matcher" do
        assert_equal 'big time failure', @error.message
      end
    end
  end

  context "a non-matching matcher" do
    setup do
      @matcher = stub('matcher', :matches?                 => false,
                                 :failure_message          => 'big time failure',
                                 :negative_failure_message => 'bad failure message')
    end

    should "pass when given to assert_rejects with no message expectation" do
      assert_rejects @matcher, 'target'
    end

    should "pass when given to assert_rejects with a matching message" do
      assert_rejects @matcher, 'target', :message => /big time/
    end

    should "fail when given to assert_rejects with a non-matching message" do
      assert_raise Test::Unit::AssertionFailedError do
        assert_rejects @matcher, 'target', :message => /small time/
      end
    end

    context "when given to assert_accepts" do
      setup do
        begin
          assert_accepts @matcher, 'target'
        rescue Test::Unit::AssertionFailedError => @error
        end
      end

      should "fail" do
        assert_not_nil @error
      end

      should "use the error message from the matcher" do
        assert_equal 'big time failure', @error.message
      end
    end
  end

  context "given one treat exists and one post exists" do
    setup do
      Treat.create!
      Post.create!(:title => 'title', :body => 'body', :user_id => 1)
    end

    teardown do
      Treat.delete_all
      Post.delete_all
    end

    context "creating a treat" do
      setup do
        Treat.create!
      end

      should_create :treat
      should_fail do
        should_create :post
      end
    end

    context "creating a treat and a post" do
      setup do
        Treat.create!
        Post.create!(:title => 'title 2', :body => 'body', :user_id => 1)
      end

      should_create :treat
      should_create :post
    end

    context "destroying a treat" do
      setup do
        Treat.first.destroy
      end

      should_destroy :treat
      should_fail do
        should_destroy :post
      end
    end

    context "destroying a treat and a post" do
      setup do
        Treat.first.destroy
        Post.first.destroy
      end

      should_destroy :treat
      should_destroy :post
    end

    context "doing nothing" do
      should_fail do
        should_create :treat
      end

      should_fail do
        should_destroy :treat
      end
    end
  end
end
