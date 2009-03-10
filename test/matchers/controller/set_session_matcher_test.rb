require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class SetSessionMatcherTest < ActionController::TestCase # :nodoc:

  context "a controller that sets a session variable" do
    setup do
      @controller = build_response do
        session[:var] = 'value'
        session[:false_var] = false
      end
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

    should "accept assigning nil to another variable" do
      assert_accepts set_session(:other).to(nil), @controller
    end

    should "accept assigning false to that variable" do
      assert_accepts set_session(:false_var).to(false), @controller
    end
  end

end
