require File.join(File.dirname(__FILE__), '..', 'test_helper')

class ShouldTest < Test::Unit::TestCase # :nodoc:

  should "run a :before proc", :before => lambda { @value = "before" } do
    assert_equal "before", @value
  end

  context "A :before proc" do
    setup do
      assert "before", @value
      @value = "setup"
    end

    should "run before the current setup", :before => lambda { @value = "before" } do
      assert_equal "setup", @value
    end
  end

  context "A context" do
    setup do
      @value = "outer"
    end

    context "with a subcontext and a :before proc" do
      before = lambda do
        assert "outer", @value
        @value = "before"
      end
      should "run after the parent setup", :before => before do
        assert_equal "before", @value
      end
    end
  end

end
