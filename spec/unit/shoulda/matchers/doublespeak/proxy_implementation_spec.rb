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
      it 'calls #call_original_method on the double' do
        stub_implementation = build_stub_implementation
        double = build_double
        call = build_call(double: double)
        allow(double).to receive(:call_original_method)
        implementation = described_class.new(stub_implementation)

        implementation.call(call)

        expect(double).
          to have_received(:call_original_method).
          with(call)
      end

      it 'delegates to its stub_implementation' do
        stub_implementation = build_stub_implementation
        double = build_double
        call2 = build_call
        call = build_call(double: double, with_return_value: call2)
        allow(double).to receive(:call_original_method)
        implementation = described_class.new(stub_implementation)

        implementation.call(call)

        expect(stub_implementation).
          to have_received(:call).
          with(call2)
      end

      it 'returns the return value of the original method' do
        return_value = :some_return_value
        stub_implementation = build_stub_implementation
        double = build_double(call_original_method: return_value)
        call = build_call(double: double)
        implementation = described_class.new(stub_implementation)

        return_value = implementation.call(call)

        expect(return_value).to be return_value
      end
    end

    def build_stub_implementation
      double('stub_implementation', returns: nil, call: nil)
    end

    def build_double(methods = {})
      defaults = { call_original_method: nil }
      double('double', defaults.merge(methods))
    end

    def build_call(methods = {})
      defaults = { double: build_double, with_return_value: nil }
      double('call', defaults.merge(methods))
    end
  end
end
