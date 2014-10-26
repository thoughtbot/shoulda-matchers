require 'spec_helper'

module Shoulda::Matchers::Doublespeak
  describe DoubleImplementationRegistry do
    describe '.find' do
      it 'returns an instance of StubImplementation if given :stub' do
        expect(described_class.find(:stub)).to be_a(StubImplementation)
      end

      it 'returns ProxyImplementation if given :proxy' do
        expect(described_class.find(:proxy)).to be_a(ProxyImplementation)
      end

      it 'raises an ArgumentError if not given a registered implementation' do
        expect {
          expect(described_class.find(:something_else))
        }.to raise_error(ArgumentError)
      end
    end
  end
end
