require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class AssignToMatcherTest < ActionController::TestCase # :nodoc:

  context "a controller that assigns to an instance variable" do
    setup do
      @controller = build_response { @var = 'value' }
    end

    should "accept assigning to that variable" do
      assert_accepts assign_to(:var), @controller
    end

    should "accept assigning to that variable with the correct class" do
      assert_accepts assign_to(:var).with_kind_of(String), @controller
    end

    should "reject assigning to that variable with another class" do
      assert_rejects assign_to(:var).with_kind_of(Fixnum), @controller
    end

    should "accept assigning the correct value to that variable" do
      assert_accepts assign_to(:var).with('value'), @controller
    end

    should "reject assigning another value to that variable" do
      assert_rejects assign_to(:var).with('other'), @controller
    end

    should "reject assigning to another variable" do
      assert_rejects assign_to(:other), @controller
    end
  end

end
