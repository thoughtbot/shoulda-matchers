require 'unit_spec_helper'

describe Shoulda::Matchers::ActionController::SetFlashMatcher, type: :controller do
  it_behaves_like 'set session or flash matcher' do
    def store_name
      'flash'
    end

    def set_store
      set_flash
    end

    def store_within(controller)
      controller.flash
    end
  end

  it_behaves_like 'set session or flash matcher' do
    def store_name
      'flash.now'
    end

    def set_store
      set_flash.now
    end

    def store_within(controller)
      controller.flash.now
    end
  end

  context 'when the controller sets both flash and flash.now' do
    it 'does not mix flash and flash.now' do
      controller = build_fake_response do
        flash['key for flash'] = 'value for flash'
        flash.now['key for flash.now'] = 'value for flash.now'
      end

      expect(controller).not_to set_flash['key for flash.now']
      expect(controller).not_to set_flash.now['key for flash']
    end
  end

  context 'when the now qualifier is called after the key is set' do
    it 'raises a error' do
      controller = build_fake_response

      expect do
        expect(controller).to set_flash['key for flash.now'].now
      end.to raise_error(described_class::QualiferOrderError, /`now` qualifier/)
    end
  end

  context 'when the now qualifier is called after the to qualifier' do
    it 'raises a error' do
      controller = build_fake_response

      expect do
        expect(controller).to set_flash.to('value for flash').now
      end.to raise_error(described_class::QualiferOrderError, /`now` qualifier/)
    end
  end
end
