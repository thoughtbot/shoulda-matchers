require File.join(File.dirname(__FILE__), '..', 'test_helper')

class PrivateHelpersTest < Test::Unit::TestCase # :nodoc:
  include ThoughtBot::Shoulda::ActiveRecord
  context "get_options!" do
    should "remove opts from args" do
      args = [:a, :b, {}]
      get_options!(args)
      assert_equal [:a, :b], args
    end

    should "return wanted opts in order" do      
      args = [{:one => 1, :two => 2}]
      one, two = get_options!(args, :one, :two)
      assert_equal 1, one
      assert_equal 2, two
    end

    should "raise ArgumentError if given unwanted option" do
      args = [{:one => 1, :two => 2}]
      assert_raises ArgumentError do
        get_options!(args, :one)
      end
    end
  end
end
