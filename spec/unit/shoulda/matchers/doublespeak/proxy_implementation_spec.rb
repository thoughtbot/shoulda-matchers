require 'unit_spec_helper'

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
        double = build_double
        implementation = described_class.new(stub_implementation)
        implementation.call(double, :object, :args, :block)

        expect(stub_implementation).
          to have_received(:call).
          with(double, :object, :args, :block)
      end

      it 'calls #call_original_method on the double' do
        stub_implementation = build_stub_implementation
        implementation = described_class.new(stub_implementation)
        double = build_double
        implementation.call(double, :object, :args, :block)

        expect(double).
          to have_received(:call_original_method).
          with(:object, :args, :block)
      end
    end

    def build_stub_implementation
      double('stub_implementation', returns: nil, call: nil)
    end

    def build_double
      double('double', call_original_method: nil)
    end
  end
end
