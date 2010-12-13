require 'spec_helper'

describe Shoulda::ActionController::Matchers::SetTheFlashMatcher do

  context "a controller that sets a flash message" do
    before do
      @controller = build_response { flash[:notice] = 'value' }
    end

    it "should accept setting any flash message" do
      @controller.should set_the_flash
    end

    it "should accept setting the exact flash message" do
      @controller.should set_the_flash.to('value')
    end

    it "should accept setting a matched flash message" do
      @controller.should set_the_flash.to(/value/)
    end

    it "should reject setting a different flash message" do
      @controller.should_not set_the_flash.to('other')
    end

    it "should reject setting a different pattern" do
      @controller.should_not set_the_flash.to(/other/)
    end
  end

  context "a controller that sets a flash.now message" do
    before do
      @controller = build_response { flash.now[:notice] = 'value' }
    end

    it "should reject setting any flash message" do
      @controller.should_not set_the_flash
    end

    it "should accept setting any flash.now message" do
      @controller.should set_the_flash.now
    end

    it "should accept setting the exact flash.now message" do
      @controller.should set_the_flash.to('value').now
    end

    it "should accept setting a matched flash.now message" do
      @controller.should set_the_flash.to(/value/).now
    end

    it "should reject setting a different flash.now message" do
      @controller.should_not set_the_flash.to('other').now
    end

    it "should reject setting a different flash.now pattern" do
      @controller.should_not set_the_flash.to(/other/).now
    end
  end

  context "a controller that sets multiple flash messages" do
    before do
      @controller = build_response {
        flash.now[:notice] = 'value'
        flash[:success] = 'great job'
      }
    end

    it "should accept setting any flash.now message" do
      @controller.should set_the_flash.now
      @controller.should set_the_flash
    end

    it "should accept setting a matched flash.now message" do
      @controller.should set_the_flash.to(/value/).now
      @controller.should set_the_flash.to(/great/)
    end

    it "should reject setting a different flash.now message" do
      @controller.should_not set_the_flash.to('other').now
      @controller.should_not set_the_flash.to('other')
    end
  end

  context "a controller that doesn't set a flash message" do
    before do
      @controller = build_response
    end

    it "should reject setting any flash message" do
      @controller.should_not set_the_flash
    end
  end

end
