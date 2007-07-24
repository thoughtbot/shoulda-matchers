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

  context "The public" do
    setup do
      @request.session[:logged_in] = false
    end

    should_be_restful do |resource|
      resource.parent = :user

      resource.denied.actions = [:index, :show, :edit, :new, :create, :update, :destroy]
      resource.denied.flash = /what/i
      resource.denied.redirect = '"/"'
    end    
  end

  context "Logged in" do
    setup do
      @request.session[:logged_in] = true
    end
    
    should_be_restful do |resource|
      resource.parent = :user

      resource.create.params = { :title => "first post", :body => 'blah blah blah'}
      resource.update.params = { :title => "changed" }
    end
  end
end
