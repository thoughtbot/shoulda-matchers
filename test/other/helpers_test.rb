require File.join(File.dirname(__FILE__), '..', 'test_helper')

class Val
  @@val = 0
  def self.val; @@val; end
  def self.inc(i=1); @@val += i; end
end

class HelpersTest < Test::Unit::TestCase # :nodoc:

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
end
