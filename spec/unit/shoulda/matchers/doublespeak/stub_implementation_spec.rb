require 'spec_helper'

module Shoulda::Matchers::Doublespeak
  describe StubImplementation do
    describe '#call' do
      it 'calls #record_call on the double' do
        implementation = described_class.new
        double = build_double

        double.expects(:record_call).with(:args, :block)

        implementation.call(double, :object, :args, :block)
      end

      context 'if no explicit implementation was set' do
        it 'returns nil' do
          implementation = described_class.new
          double = build_double

          return_value = implementation.call(double, :object, :args, :block)

          expect(return_value).to eq nil
        end
      end

      context 'if the implementation was set as a value' do
        it 'returns the set return value' do
          implementation = described_class.new
          implementation.returns(42)
          double = build_double

          return_value = implementation.call(double, :object, :args, :block)

          expect(return_value).to eq 42
        end
      end

      context 'if the implementation was set as a block' do
        it 'calls the block with the object and args/block passed to the method' do
          double = build_double
          expected_object, expected_args, expected_block = :object, :args, :block
          actual_object, actual_args, actual_block = []
          implementation = described_class.new
          implementation.returns do |object, args, block|
            actual_object, actual_args, actual_block = object, args, block
          end

          implementation.call(
            double,
            expected_object,
            expected_args,
            expected_block
          )

          expect(actual_object).to eq expected_object
          expect(actual_args).to eq expected_args
          expect(actual_block).to eq expected_block
        end

        it 'returns the return value of the block' do
          implementation = described_class.new
          implementation.returns { 42 }
          double = build_double

          return_value = implementation.call(double, :object, :args, :block)

          expect(return_value).to eq 42
        end
      end

      context 'if the implementation was set as both a value and a block' do
        it 'prefers the block over the value' do
          implementation = described_class.new
          implementation.returns(:something_else) { 42 }
          double = build_double

          return_value = implementation.call(double, :object, :args, :block)

          expect(return_value).to eq 42
        end
      end
    end

    def build_double
      stub(record_call: nil)
    end
  end
end
