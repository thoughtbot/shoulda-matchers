require File.dirname(__FILE__) + '/../test_helper'
require 'posts_controller'

# Re-raise errors caught by the controller.
class PostsController; def rescue_action(e) raise e end; end

class PostsControllerTest < Test::Unit::TestCase
  fixtures :all

  def setup
    @controller = PostsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @post       = Post.find(:first)
  end

  # autodetects the :controller
  should_route :get,    '/posts',     :action => :index
  # explicitly specify :controller
  should_route :post,   '/posts',     :controller => :posts, :action => :create
  # non-string parameter
  should_route :get,    '/posts/1',   :action => :show, :id => 1
  # string-parameter
  should_route :put,    '/posts/1',   :action => :update, :id => "1"
  should_route :delete, '/posts/1',   :action => :destroy, :id => 1
  should_route :get,    '/posts/new', :action => :new

  # Test the nested routes
  should_route :get,    '/users/5/posts',     :action => :index, :user_id => 5
  should_route :post,   '/users/5/posts',     :action => :create, :user_id => 5
  should_route :get,    '/users/5/posts/1',   :action => :show, :id => 1, :user_id => 5
  should_route :delete, '/users/5/posts/1',   :action => :destroy, :id => 1, :user_id => 5
  should_route :get,    '/users/5/posts/new', :action => :new, :user_id => 5
  should_route :put,    '/users/5/posts/1',   :action => :update, :id => 1, :user_id => 5

  context "Logged in" do
    setup do
      @request.session[:logged_in] = true
    end

    context "viewing posts for a user" do
      setup do
        get :index, :user_id => users(:first)
      end
      should_respond_with :success
      should_assign_to :user, :class => User, :equals => 'users(:first)'
      should_assign_to(:user) { users(:first) }
      should_fail do
        should_assign_to :user, :class => Post
      end
      should_fail do
        should_assign_to :user, :equals => 'posts(:first)'
      end
      should_fail do
        should_assign_to(:user) { posts(:first) }
      end
      should_assign_to :posts
      should_not_assign_to :foo, :bar
      should_render_page_with_metadata :description => /Posts/, :title => /index/
      should_render_page_with_metadata :keywords => "posts"
    end

    context "viewing posts for a user with rss format" do
      setup do
        get :index, :user_id => users(:first), :format => 'rss'
        @user = users(:first)
      end
      should_respond_with :success
      should_respond_with_content_type 'application/rss+xml'
      should_respond_with_content_type :rss
      should_respond_with_content_type /rss/
      context "deprecated" do # to avoid redefining a test
        should_return_from_session :special, "'$2 off your next purchase'"
      end
      should_fail do
        should_return_from_session :special, "'not special'"
      end
      should_set_session(:mischief) { nil }
      should_return_from_session :malarky, "nil"
      should_set_session :special, "'$2 off your next purchase'"
      should_set_session :special_user_id, '@user.id'
      context "with a block" do
        should_set_session(:special_user_id) { @user.id }
      end
      should_fail do # to avoid redefining a test
        should_set_session(:special_user_id) { 'value' }
      end
      should_assign_to :user, :posts
      should_not_assign_to :foo, :bar
    end

    context "viewing a post on GET to #show" do
      setup { get :show, :user_id => users(:first), :id => posts(:first) }
      should_render_with_layout 'wide'
      context "with a symbol" do # to avoid redefining a test
        should_render_with_layout :wide
      end
      should_assign_to :false_flag
    end

    context "on GET to #new" do
      setup { get :new, :user_id => users(:first) }
      should_render_without_layout
    end

    context "on POST to #create" do
      setup do
        post :create, :user_id => users(:first),
                      :post    => { :title => "first post",
                                    :body  => 'blah blah blah' }
      end

      should_redirect_to 'user_post_url(@post.user, @post)'
      should_redirect_to('the created post') { user_post_url(users(:first),
                                                             assigns(:post)) }
      should_fail do
        should_redirect_to 'user_posts_url(@post.user)'
      end
      should_fail do
        should_redirect_to('elsewhere') { user_posts_url(users(:first)) }
      end
    end
  end

end
