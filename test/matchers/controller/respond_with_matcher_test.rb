require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class RespondWithMatcherTest < Test::Unit::TestCase # :nodoc:

  context "a controller responding with success" do
    setup do
      @controller = build_response { render :text => "text", :status => 200 }
    end

    should "accept responding with 200" do
      assert_accepts respond_with(200), @controller
    end
    
    should "accept responding with :success" do
      assert_accepts respond_with(:success), @controller
    end
    
    should "reject responding with another status" do
      assert_rejects respond_with(:error), @controller
    end
  end
  
  context "a controller responding with redirect" do
    setup do
      @controller = build_response { render :text => "text", :status => 301 }
    end

    should "accept responding with 301" do
      assert_accepts respond_with(301), @controller
    end
    
    should "accept responding with :redirect" do
      assert_accepts respond_with(:redirect), @controller
    end
    
    should "reject responding with another status" do
      assert_rejects respond_with(:error), @controller
    end
  end
  
  context "a controller responding with missing" do
    setup do
      @controller = build_response { render :text => "text", :status => 404 }
    end

    should "accept responding with 404" do
      assert_accepts respond_with(404), @controller
    end
    
    should "accept responding with :missing" do
      assert_accepts respond_with(:missing), @controller
    end
    
    should "reject responding with another status" do
      assert_rejects respond_with(:success), @controller
    end
  end
  
  context "a controller responding with error" do
    setup do
      @controller = build_response { render :text => "text", :status => 500 }
    end

    should "accept responding with 500" do
      assert_accepts respond_with(500), @controller
    end
    
    should "accept responding with :error" do
      assert_accepts respond_with(:error), @controller
    end
    
    should "reject responding with another status" do
      assert_rejects respond_with(:success), @controller
    end
  end
  
  context "a controller responding with not implemented" do
    setup do
      @controller = build_response { render :text => "text", :status => 501 }
    end

    should "accept responding with 501" do
      assert_accepts respond_with(501), @controller
    end
    
    should "accept responding with :not_implemented" do
      assert_accepts respond_with(:not_implemented), @controller
    end
    
    should "reject responding with another status" do
      assert_rejects respond_with(:success), @controller
    end
  end
  
  context "a controller raising an error" do
    setup do
      @controller = build_response { raise RailsError }
    end

    should "reject responding with any status" do
      assert_rejects respond_with(:success), @controller
    end
  end

end

