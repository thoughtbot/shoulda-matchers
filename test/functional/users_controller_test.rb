require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase
  load_all_fixtures

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @user       = User.find(:first)
  end

  should_be_restful do |resource|
    resource.create.params = { :name => "bob", :email => 'bob@bob.com', :age => 13}
    resource.update.params = { :name => "sue" }
    
    resource.create.redirect  = "user_url(record)"
    resource.update.redirect  = "user_url(record)"
    resource.destroy.redirect = "users_url"
  end
end
