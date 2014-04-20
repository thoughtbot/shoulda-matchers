require 'spec_helper'

module Shoulda::Matchers::Doublespeak
  describe ProxyImplementation do
    describe '#returns' do
      it 'delegates to its stub_implementation' do
        stub_implementation = build_stub_implementation
        stub_implementation.expects(:returns).with(:value)
        implementation = described_class.new(stub_implementation)
        implementation.returns(:value)
      end
    end

    describe '#call' do
      it 'delegates to its stub_implementation' do
        stub_implementation = build_stub_implementation
        double = build_double
        stub_implementation.expects(:call).with(double, :object, :args, :block)
        implementation = described_class.new(stub_implementation)
        implementation.call(double, :object, :args, :block)
      end

      it 'calls #call_original_method on the double' do
        stub_implementation = build_stub_implementation
        implementation = described_class.new(stub_implementation)
        double = build_double
        double.expects(:call_original_method).with(:object, :args, :block)
        implementation.call(double, :object, :args, :block)
      end
    end

    def build_stub_implementation
      stub(returns: nil, call: nil)
    end

    def build_double
      stub(call_original_method: nil)
    end
  end
end
