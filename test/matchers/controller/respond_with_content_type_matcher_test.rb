require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class RespondWithContentTypeMatcherTest < ActionController::TestCase # :nodoc:

  context "a controller responding with content type :xml" do
    setup do
      @controller = build_response { render :xml => { :user => "thoughtbot" }.to_xml }
    end

    should "accept responding with content type :xml" do
      assert_accepts respond_with_content_type(:xml), @controller
    end

    should "accept responding with content type 'application/xml'" do
      assert_accepts respond_with_content_type('application/xml'), @controller
    end

    should "accept responding with content type /xml/" do
      assert_accepts respond_with_content_type(/xml/), @controller
    end

    should "reject responding with another content type" do
      assert_rejects respond_with_content_type(:json), @controller
    end
  end

  should "generate the correct test name" do
    assert_equal "respond with content type of application/xml",
                 respond_with_content_type(:xml).description
  end

end
