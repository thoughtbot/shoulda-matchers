require 'spec_helper'

describe Shoulda::Matchers::ActionController::SetTheFlashMatcher do
  it 'fails with unmatchable #to' do
    expect { set_the_flash.to(1) }.to raise_error('cannot match against 1')
  end

  context 'a controller that sets a flash message' do
    it 'accepts setting any flash message' do
      controller_with_flash(:notice => 'hi').should set_the_flash
    end

    it 'accepts setting the exact flash message' do
      controller_with_flash(:notice => 'hi').should set_the_flash.to('hi')
    end

    it 'accepts setting a matched flash message' do
      controller_with_flash(:notice => 'hello').should set_the_flash.to(/he/)
    end

    it 'rejects setting a different flash message' do
      controller_with_flash(:notice => 'hi').
        should_not set_the_flash.to('other')
    end

    it 'rejects setting a different pattern' do
      controller_with_flash(:notice => 'hi').
        should_not set_the_flash.to(/other/)
    end
  end

  context 'a controller that sets a flash.now message' do
    it 'rejects setting any flash message' do
      controller_with_flash_now.should_not set_the_flash
    end

    it 'accepts setting any flash.now message' do
      controller_with_flash_now.should set_the_flash.now
    end

    it 'accepts setting the exact flash.now message' do
      controller_with_flash_now(:notice => 'hi').
        should set_the_flash.now.to('hi')
    end

    it 'accepts setting a matched flash.now message' do
      controller_with_flash_now(:notice => 'flasher').
        should set_the_flash.now.to(/lash/)
    end

    it 'rejects setting a different flash.now message' do
      controller_with_flash_now(:notice => 'hi').
        should_not set_the_flash.now.to('other')
    end

    it 'rejects setting a different flash.now pattern' do
      controller_with_flash_now(:notice => 'hi').
        should_not set_the_flash.now.to(/other/)
    end
  end

  context 'a controller that sets flash messages for multiple keys' do
    it 'accepts flash message for either key' do
      controller = controller_with_flash(:notice => 'one', :alert => 'two')

      controller.should set_the_flash[:notice]
      controller.should set_the_flash[:alert]
    end

    it 'rejects a flash message that is not one of the set keys' do
      controller_with_flash(:notice => 'one', :alert => 'two').
        should_not set_the_flash[:warning]
    end

    it 'accepts exact flash message of notice' do
      controller_with_flash(:notice => 'one', :alert => 'two').
        should set_the_flash[:notice].to('one')
    end

    it 'accepts setting a matched flash message of notice' do
      controller_with_flash(:notice => 'one', :alert => 'two').
        should set_the_flash[:notice].to(/on/)
    end

    it 'rejects setting a different flash message of notice' do
      controller_with_flash(:notice => 'one', :alert => 'two').
        should_not set_the_flash[:notice].to('other')
    end

    it 'rejects setting a different pattern' do
      controller_with_flash(:notice => 'one', :alert => 'two').
        should_not set_the_flash[:notice].to(/other/)
    end
  end

  context 'a controller that sets flash and flash.now' do
    it 'accepts setting any flash.now message' do
      controller = build_response do
        flash.now[:notice] = 'value'
        flash[:success] = 'great job'
      end

      controller.should set_the_flash.now
      controller.should set_the_flash
    end

    it 'accepts setting a matched flash.now message' do
      controller = build_response do
        flash.now[:notice] = 'value'
        flash[:success] = 'great job'
      end

      controller.should set_the_flash.now.to(/value/)
      controller.should set_the_flash.to(/great/)
    end

    it 'rejects setting a different flash.now message' do
      controller = build_response do
        flash.now[:notice] = 'value'
        flash[:success] = 'great job'
      end

      controller.should_not set_the_flash.now.to('other')
      controller.should_not set_the_flash.to('other')
    end
  end

  context 'a controller that does not set a flash message' do
    it 'rejects setting any flash message' do
      controller_with_no_flashes.should_not set_the_flash
    end
  end

  def controller_with_no_flashes
    build_response
  end

  def controller_with_flash(flash_hash)
    build_response do
      flash_hash.each do |key, value|
        flash[key] = value
      end
    end
  end

  def controller_with_flash_now(flash_hash = { :notice => 'hi' })
    build_response do
      flash_hash.each do |key, value|
        flash.now[key] = value
      end
    end
  end
end
