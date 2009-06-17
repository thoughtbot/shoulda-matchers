require File.join(File.dirname(__FILE__), '..', 'test_helper')

class PrivateHelpersTest < ActiveSupport::TestCase # :nodoc:
  include Shoulda::Private
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
    
    should "return single wanted option" do
      args = [:a, :b, {:class => Object}]
      klass = get_options!(args,:class)
      assert_equal Object, klass
    end
  end
end
