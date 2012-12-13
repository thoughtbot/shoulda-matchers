require 'spec_helper'

describe Shoulda::Matchers::ActionController::StrongParametersMatcher do


  describe "permit" do
    it "is true when the sent parameter is allowed" do
      define_model "User", name: :string, admin: :string
      controller = define_controller "Users" do
        def create
          @user = User.create(user_params)
          render nothing: true
        end

        private

        def user_params
          params.require(:user).permit(:name)
        end
      end
      @controller = controller.new
      @request = ::ActionController::TestRequest.new
      @response = ::ActionController::TestResponse.new

      class << self
        include ActionController::TestCase::Behavior
      end

      define_routes do
        resources :users
      end


      controller.should permit(:name).for(:create)
    end
  end
end
