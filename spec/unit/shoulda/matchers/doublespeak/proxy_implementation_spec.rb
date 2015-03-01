require 'doublespeak_spec_helper'

module Shoulda::Matchers::Doublespeak
  describe ProxyImplementation do
    describe '#returns' do
      it 'delegates to its stub_implementation' do
        stub_implementation = build_stub_implementation
        implementation = described_class.new(stub_implementation)
        implementation.returns(:value)

        expect(stub_implementation).to have_received(:returns).with(:value)
      end
    end

    describe '#call' do
      it 'delegates to its stub_implementation' do
        stub_implementation = build_stub_implementation
        call = build_call
        implementation = described_class.new(stub_implementation)

        implementation.call(call)

        expect(stub_implementation).
          to have_received(:call).
          with(call)
      end

      it 'calls #call_original_method on the double' do
        stub_implementation = build_stub_implementation
        double = build_double
        call = build_call(double: double)
        allow(double).to receive(:call_original_method).and_return(call)
        implementation = described_class.new(stub_implementation)

        implementation.call(call)

        expect(double).
          to have_received(:call_original_method).
          with(call)
      end
    end

    def build_stub_implementation
      double('stub_implementation', returns: nil, call: nil)
    end

    def build_double
      double('double', call_original_method: nil)
    end

    def build_call(double: build_double)
      double('call', double: double)
    end
  end
end
