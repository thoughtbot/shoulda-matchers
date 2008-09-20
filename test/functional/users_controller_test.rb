require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase
  fixtures :all

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @user       = User.find(:first)
  end

  context "on GET to #index" do
    setup { get :index }

    should_respond_with :success
    should_render_with_layout 'users'
    should_render_template :index
    should_assign_to :users
  end
  
  context "on GET to #index.xml" do
    setup { get :index, :format => 'xml' }
  
    should_respond_with :success
    should_respond_with_xml_for
    should_assign_to :users
  end
  
  context "on GET to #show" do
    setup { get :show, :id => @user }

    should_respond_with :success
    should_render_with_layout 'users'
    should_render_template :show
    should_assign_to :user
  end
  
end
