require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class RouteToMatcherTest < ActionController::TestCase # :nodoc:

  context "given a controller with a defined glob url" do
    setup do
      @controller = define_controller('Examples').new
      define_routes do |map|
        map.connect 'examples/*id', :controller => 'examples',
                                    :action     => 'example'
      end
    end

    should "accept glob route" do
      assert_accepts route(:get, '/examples/foo/bar').
                      to(:action => 'example', :id => ['foo', 'bar']),
                    @controller
    end

  end

  context "given a controller with a defined route" do
    setup do
      @controller = define_controller('Examples').new
      define_routes do |map|
        map.connect 'examples/:id', :controller => 'examples',
                                    :action     => 'example'
      end
    end

    should "accept routing the correct path to the correct parameters" do
      assert_accepts route(:get, '/examples/1').
                       to(:action => 'example', :id => '1'),
                     @controller
    end

    should "accept a symbol controller" do
      assert_accepts route(:get, '/examples/1').
                       to(:controller => :examples, 
                          :action     => 'example',
                          :id         => '1'),
                     self
    end

    should "accept a symbol action" do
      assert_accepts route(:get, '/examples/1').
                       to(:action => :example, :id => '1'), 
                     @controller
    end

    should "accept a non-string parameter" do
      assert_accepts route(:get, '/examples/1').
                       to(:action => 'example', :id => 1),
                     @controller
    end

    should "reject an undefined route" do
      assert_rejects route(:get, '/bad_route').to(:var => 'value'), @controller
    end

    should "reject a route for another controller" do
      @other = define_controller('Other').new
      assert_rejects route(:get, '/examples/1').
                       to(:action => 'example', :id => '1'),
                     @other
    end

    should "reject a route for different parameters" do
      assert_rejects route(:get, '/examples/1').
                       to(:action => 'other', :id => '1'),
                     @controller
    end
  end

end
