require 'spec_helper'

describe Shoulda::Matchers::ActionController do
  describe ".permit" do
    before do
      define_model "User"
      @controller_class = define_controller "Users" do
        def create
          @user = User.create(user_params)
          render nothing: true
        end

        private
        def user_params
          params.require(:user).permit(:name)
        end
      end

      setup_rails_controller_test(@controller_class)

      define_routes { resources :users }
    end

    it "is true when the sent parameter is allowed" do
      @controller_class.should permit(:name).for(:create)
    end

    it "is false when the sent parameter is not allowed" do
      @controller_class.should_not permit(:admin).for(:create)
    end
  end
end

describe Shoulda::Matchers::ActionController::StrongParametersMatcher do
end
