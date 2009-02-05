require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class SetSessionMatcherTest < Test::Unit::TestCase # :nodoc:

  context "a controller that sets a session variable" do
    setup do
      @controller = build_response { session[:var] = 'value' }
    end

    should "accept assigning to that variable" do
      assert_accepts set_session(:var), @controller
    end

    should "accept assigning the correct value to that variable" do
      assert_accepts set_session(:var).to('value'), @controller
    end

    should "reject assigning another value to that variable" do
      assert_rejects set_session(:var).to('other'), @controller
    end

    should "reject assigning to another variable" do
      assert_rejects set_session(:other), @controller
    end
  end

end
