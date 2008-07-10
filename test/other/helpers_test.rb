require File.join(File.dirname(__FILE__), '..', 'test_helper')
require 'action_mailer'
require 'mocha'

class HelpersTest < Test::Unit::TestCase # :nodoc:

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

      should_change "@a.length", :by => 3
      should_change "@a.length", :from => 3, :to => 6, :by => 3
      should_change "@a[0]"
      should_change "@a[1]", :from => 2, :to => "b"
      should_change "@a[2]", :from => /\d/, :to => /\w/
      should_change "@a[3]", :to => String
    end
  end
end
