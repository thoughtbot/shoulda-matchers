require 'spec_helper'

if ActiveRecord::Base.respond_to? :has_secure_password
  describe Shoulda::Matchers::ActiveModel::HaveSecurePasswordMatcher do
    context "a model that does have secure password" do
      before do
        define_model :example do
          has_secure_password
        end
        @model = Example.new
      end

      it "should accept having a secure password" do
        @model.should have_secure_password
      end
    end

    context "a Model that does not have secure password" do
      before do
        define_model :example do
        end
        @model = Example.new
      end

      it "should not accept having a secure password" do
        @model.should_not have_secure_password
      end
    end
  end
end
