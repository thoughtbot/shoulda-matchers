require 'spec_helper'

describe Shoulda::Matchers::Independent::DelegateMatcher::StubbedTarget do
  subject(:target) { described_class.new(:stubbed_method) }

  describe '#has_received_method?' do
    it 'returns true when the method has been called on the target' do
      target.stubbed_method

      expect(target).to have_received_method
    end

    it 'returns false when the method has not been called on the target' do
      expect(target).not_to have_received_method
    end
  end

  describe '#has_received_arguments?' do
    context 'method is called with specified arguments' do
      it 'returns true' do
        target.stubbed_method(:arg1, :arg2)

        expect(target).to have_received_arguments(:arg1, :arg2)
      end
    end

    context 'method is not called with specified arguments' do
      it 'returns false' do
        target.stubbed_method

        expect(target).not_to have_received_arguments(:arg1)
      end
    end

    context 'method is called with arguments in incorrect order' do
      it 'returns false' do
        target.stubbed_method(:arg2, :arg1)

        expect(target).not_to have_received_arguments(:arg1, :arg2)
      end
    end
  end
end
