require 'spec_helper'

describe Shoulda::Matchers::ActionController::SetTheFlashMatcher do
  it 'fails with unmatchable #to' do
    expect { set_the_flash.to(1) }.to raise_error('cannot match against 1')
  end

  context 'a controller that sets a flash message' do
    it 'accepts setting any flash message' do
      expect(controller_with_flash(notice: 'hi')).to set_the_flash
    end

    it 'accepts setting the exact flash message' do
      expect(controller_with_flash(notice: 'hi')).to set_the_flash.to('hi')
    end

    it 'accepts setting a matched flash message' do
      expect(controller_with_flash(notice: 'hello')).to set_the_flash.to(/he/)
    end

    it 'rejects setting a different flash message' do
      expect(controller_with_flash(notice: 'hi')).
        not_to set_the_flash.to('other')
    end

    it 'rejects setting a different pattern' do
      expect(controller_with_flash(notice: 'hi')).
        not_to set_the_flash.to(/other/)
    end
  end

  context 'a controller that sets a flash.now message' do
    it 'rejects setting any flash message' do
      expect(controller_with_flash_now).not_to set_the_flash
    end

    it 'accepts setting any flash.now message' do
      expect(controller_with_flash_now).to set_the_flash.now
    end

    it 'accepts setting the exact flash.now message' do
      expect(controller_with_flash_now(notice: 'hi')).
        to set_the_flash.now.to('hi')
    end

    it 'accepts setting a matched flash.now message' do
      expect(controller_with_flash_now(notice: 'flasher')).
        to set_the_flash.now.to(/lash/)
    end

    it 'rejects setting a different flash.now message' do
      expect(controller_with_flash_now(notice: 'hi')).
        not_to set_the_flash.now.to('other')
    end

    it 'rejects setting a different flash.now pattern' do
      expect(controller_with_flash_now(notice: 'hi')).
        not_to set_the_flash.now.to(/other/)
    end
  end

  context 'a controller that sets flash messages for multiple keys' do
    it 'accepts flash message for either key' do
      controller = controller_with_flash(notice: 'one', alert: 'two')

      expect(controller).to set_the_flash[:notice]
      expect(controller).to set_the_flash[:alert]
    end

    it 'rejects a flash message that is not one of the set keys' do
      expect(controller_with_flash(notice: 'one', alert: 'two')).
        not_to set_the_flash[:warning]
    end

    it 'accepts exact flash message of notice' do
      expect(controller_with_flash(notice: 'one', alert: 'two')).
        to set_the_flash[:notice].to('one')
    end

    it 'accepts setting a matched flash message of notice' do
      expect(controller_with_flash(notice: 'one', alert: 'two')).
        to set_the_flash[:notice].to(/on/)
    end

    it 'rejects setting a different flash message of notice' do
      expect(controller_with_flash(notice: 'one', alert: 'two')).
        not_to set_the_flash[:notice].to('other')
    end

    it 'rejects setting a different pattern' do
      expect(controller_with_flash(notice: 'one', alert: 'two')).
        not_to set_the_flash[:notice].to(/other/)
    end
  end

  context 'a controller that sets flash and flash.now' do
    it 'accepts setting any flash.now message' do
      controller = build_fake_response do
        flash.now[:notice] = 'value'
        flash[:success] = 'great job'
      end

      expect(controller).to set_the_flash.now
      expect(controller).to set_the_flash
    end

    it 'accepts setting a matched flash.now message' do
      controller = build_fake_response do
        flash.now[:notice] = 'value'
        flash[:success] = 'great job'
      end

      expect(controller).to set_the_flash.now.to(/value/)
      expect(controller).to set_the_flash.to(/great/)
    end

    it 'rejects setting a different flash.now message' do
      controller = build_fake_response do
        flash.now[:notice] = 'value'
        flash[:success] = 'great job'
      end

      expect(controller).not_to set_the_flash.now.to('other')
      expect(controller).not_to set_the_flash.to('other')
    end
  end

  context 'a controller that does not set a flash message' do
    it 'rejects setting any flash message' do
      expect(controller_with_no_flashes).not_to set_the_flash
    end
  end

  def controller_with_no_flashes
    build_fake_response
  end

  def controller_with_flash(flash_hash)
    build_fake_response do
      flash_hash.each do |key, value|
        flash[key] = value
      end
    end
  end

  def controller_with_flash_now(flash_hash = { notice: 'hi' })
    build_fake_response do
      flash_hash.each do |key, value|
        flash.now[key] = value
      end
    end
  end
end
