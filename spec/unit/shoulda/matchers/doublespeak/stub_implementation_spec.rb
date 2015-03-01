require 'doublespeak_spec_helper'

module Shoulda::Matchers::Doublespeak
  describe StubImplementation do
    describe '#call' do
      it 'calls #record_call on the double' do
        implementation = described_class.new
        double = build_double
        call = build_call(double: double)

        allow(double).to receive(:record_call).with(call)

        implementation.call(call)
      end

      context 'if no explicit implementation was set' do
        it 'returns nil' do
          implementation = described_class.new
          double = build_double
          call = build_call(double: double)

          return_value = implementation.call(call)

          expect(return_value).to eq nil
        end
      end

      context 'if the implementation was set as a value' do
        it 'returns the set return value' do
          implementation = described_class.new
          implementation.returns(42)
          double = build_double
          call = build_call(double: double)

          return_value = implementation.call(call)

          expect(return_value).to eq 42
        end
      end

      context 'if the implementation was set as a block' do
        it 'calls the block with the MethodCall object the implementation was called with' do
          double = build_double
          expected_object, expected_args, expected_block = :object, :args, :block
          call = build_call(
            double: double,
            object: expected_object,
            args: expected_args,
            block: expected_block
          )
          actual_object, actual_args, actual_block = []
          implementation = described_class.new
          implementation.returns do |actual_call|
            actual_object = actual_call.object
            actual_args = actual_call.args
            actual_block = actual_call.block
          end

          implementation.call(call)

          expect(actual_object).to eq expected_object
          expect(actual_args).to eq expected_args
          expect(actual_block).to eq expected_block
        end

        it 'returns the return value of the block' do
          implementation = described_class.new
          implementation.returns { 42 }
          double = build_double
          call = build_call(double: double)

          return_value = implementation.call(call)

          expect(return_value).to eq 42
        end
      end

      context 'if the implementation was set as both a value and a block' do
        it 'prefers the block over the value' do
          implementation = described_class.new
          implementation.returns(:something_else) { 42 }
          double = build_double
          call = build_call(double: double)

          return_value = implementation.call(call)

          expect(return_value).to eq 42
        end
      end
    end

    def build_double
      double('double', record_call: nil)
    end

    def build_call(options = {})
      defaults = { double: build_double }
      double('call', defaults.merge(options))
    end
  end
end
