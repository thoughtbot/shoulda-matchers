require File.join(File.dirname(__FILE__), 'test_helper')

class Val
  @@val = 0
  def self.val; @@val; end
  def self.inc(i=1); @@val += i; end
end

class ContextTest < Test::Unit::TestCase # :nodoc:

  context "assert_difference" do
    should "pass when incrementing by one" do
      assert_difference(Val, :val, 1) do
        Val.inc
      end
    end

    should "pass when incrementing by two" do
      assert_difference(Val, :val, 2) do
        Val.inc(2)
      end
    end
  end

end
