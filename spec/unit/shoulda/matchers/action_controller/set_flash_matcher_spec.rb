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
    it 'raises a QualifierOrderError' do
      controller = build_fake_response

      usage = lambda do
        expect(controller).to set_flash['any key'].now
      end

      expect(&usage).to raise_error(described_class::QualifierOrderError)
    end
  end

  context 'when the now qualifier is called after the to qualifier' do
    it 'raises a QualifierOrderError' do
      controller = build_fake_response

      usage = lambda do
        expect(controller).to set_flash.to('any value').now
      end

      expect(&usage).to raise_error(described_class::QualifierOrderError)
    end
  end
end
