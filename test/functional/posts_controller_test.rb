require File.dirname(__FILE__) + '/../test_helper'
require 'posts_controller'

# Re-raise errors caught by the controller.
class PostsController; def rescue_action(e) raise e end; end

class PostsControllerTest < Test::Unit::TestCase
  load_all_fixtures

  def setup
    @controller = PostsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @post       = Post.find(:first)
  end

  should_be_restful do |resource|
    resource.parent = :user
    
    resource.create.params = { :title => "first post", :body => 'blah blah blah'}
    resource.update.params = { :title => "changed" }
    
    # resource.create.redirect  = "post_url( record.user, record)"
    # resource.update.redirect  = "post_url( record.user, record)"
    # resource.destroy.redirect = "posts_url(record.user)"
  end
end
