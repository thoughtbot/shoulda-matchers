require File.join(File.dirname(__FILE__), 'test_helper')

class ContextTest < Test::Unit::TestCase

  context "context with setup block" do
    setup do
      @blah = "blah"
    end
    
    should "have @blah == 'blah'" do
      assert_equal "blah", @blah
    end
    
    should "have name set right" do
      assert_match(/^test context with setup block/, self.to_s)
    end
  end

  context "another context with setup block" do
    setup do
      @blah = "foo"
    end
    
    should "have @blah == 'foo'" do
      assert_equal "foo", @blah
    end

    should "have name set right" do
      assert_match(/^test another context with setup block/, self.to_s)
    end
  end
  
  context "context with method definition" do
    setup do
      def hello; "hi"; end
    end
    
    should "be able to read that method" do
      assert_equal "hi", hello
    end

    should "have name set right" do
      assert_match(/^test context with method definition/, self.to_s)
    end
  end
  
  context "final context" do
    should "not define @blah" do
      assert_nil @blah
    end
    
    context "with subcontext" do
      should "be named correctly" do
        assert_match(/^test final context with subcontext should be named correctly/, self.to_s)
      end
    end
  end
  
  should_eventually "pass anyway, since it's unimplemented" do
    flunk "what?"
  end

end
