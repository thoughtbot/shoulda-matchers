require 'shoulda/controller/matchers/assign_to_matcher'
require 'shoulda/controller/matchers/filter_param_matcher'
require 'shoulda/controller/matchers/set_the_flash_matcher'

module Shoulda # :nodoc:
  module Controller # :nodoc:

    # By using the macro helpers you can quickly and easily create concise and
    # easy to read test suites.
    # 
    # This code segment:
    # 
    #   describe UsersController, "on GET to show with a valid id" do
    #     before(:each) do
    #       get :show, :id => User.first.to_param
    #     end
    # 
    #     it { should assign_to(:user) }
    #     it { should respond_with(:success) }
    #     it { should render_template(:show) }
    #     it { should not_set_the_flash) }
    # 
    #     it "should do something else really cool" do
    #       assigns[:user].id.should == 1
    #     end
    #   end
    # 
    # Would produce 5 tests for the show action
    module Matchers
    end
  end
end
