require 'spec_helper'

describe Shoulda::Matchers::ActionController::SetTheFlashMatcher do
  it "should fail with unmatchable to" do
    expect{
      set_the_flash.to(1).should
    }.to raise_error("cannot match against 1")
  end

  context "a controller that sets a flash message" do
    let(:controller) { build_response { flash[:notice] = 'value' } }

    it "should accept setting any flash message" do
      controller.should set_the_flash
    end

    it "should accept setting the exact flash message" do
      controller.should set_the_flash.to('value')
    end

    it "should accept setting a matched flash message" do
      controller.should set_the_flash.to(/value/)
    end

    it "should reject setting a different flash message" do
      controller.should_not set_the_flash.to('other')
    end

    it "should reject setting a different pattern" do
      controller.should_not set_the_flash.to(/other/)
    end
  end

  context "a controller that sets a flash.now message" do
    let(:controller) { build_response { flash.now[:notice] = 'value' } }

    it "should reject setting any flash message" do
      controller.should_not set_the_flash
    end

    it "should accept setting any flash.now message" do
      controller.should set_the_flash.now
    end

    it "should accept setting the exact flash.now message" do
      controller.should set_the_flash.to('value').now
    end

    it "should accept setting a matched flash.now message" do
      controller.should set_the_flash.to(/value/).now
    end

    it "should reject setting a different flash.now message" do
      controller.should_not set_the_flash.to('other').now
    end

    it "should reject setting a different flash.now pattern" do
      controller.should_not set_the_flash.to(/other/).now
    end
  end

  context "a controller that sets a flash message of notice and alert" do
    let(:controller) do
      build_response do
        flash[:notice] = 'value'
        flash[:alert]  = 'other'
      end
    end

    it "should accept flash message of notice" do
      controller.should set_the_flash[:notice]
    end

    it "should accept flash message of alert" do
      controller.should set_the_flash[:notice]
    end

    it "should reject flash message of warning" do
      controller.should_not set_the_flash[:warning]
    end

    it "should accept exact flash message of notice" do
      controller.should set_the_flash[:notice].to('value')
    end

    it "should accept setting a matched flash message of notice" do
      controller.should set_the_flash[:notice].to(/value/)
    end

    it "should reject setting a different flash message of notice" do
      controller.should_not set_the_flash[:notice].to('other')
    end

    it "should reject setting a different pattern" do
      controller.should_not set_the_flash[:notice].to(/other/)
    end
  end

  context "a controller that sets multiple flash messages" do
    let(:controller) do
      build_response do
        flash.now[:notice] = 'value'
        flash[:success] = 'great job'
      end
    end

    it "should accept setting any flash.now message" do
      controller.should set_the_flash.now
      controller.should set_the_flash
    end

    it "should accept setting a matched flash.now message" do
      controller.should set_the_flash.to(/value/).now
      controller.should set_the_flash.to(/great/)
    end

    it "should reject setting a different flash.now message" do
      controller.should_not set_the_flash.to('other').now
      controller.should_not set_the_flash.to('other')
    end
  end

  context "a controller that doesn't set a flash message" do
    let(:controller) { build_response }

    it "should reject setting any flash message" do
      controller.should_not set_the_flash
    end
  end
end
