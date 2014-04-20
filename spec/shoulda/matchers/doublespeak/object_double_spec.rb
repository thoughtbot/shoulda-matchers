require 'spec_helper'

module Shoulda::Matchers::Doublespeak
  describe ObjectDouble do
    it 'responds to any method' do
      double = described_class.new

      expect(double.respond_to?(:foo)).to be_true
      expect(double.respond_to?(:bar)).to be_true
      expect(double.respond_to?(:baz)).to be_true
    end

    it 'returns nil from any method call' do
      double = described_class.new

      expect(double.foo).to be_nil
      expect(double.bar).to be_nil
      expect(double.baz).to be_nil
    end

    it 'records every method call' do
      double = described_class.new

      block = -> { :some_return_value }
      double.foo
      double.bar(42)
      double.baz(:zing, :zang, &block)

      expect(double.calls.size).to eq 3
      double.calls[0].tap do |call|
        expect(call.args).to eq []
        expect(call.block).to eq nil
      end
      double.calls[1].tap do |call|
        expect(call.args).to eq [42]
        expect(call.block).to eq nil
      end
      double.calls[2].tap do |call|
        expect(call.args).to eq [:zing, :zang]
        expect(call.block).to eq block
      end
    end

    describe '#calls_to' do
      it 'returns all of the invocations of the given method and their arguments/block' do
        double = described_class.new

        block = -> { :some_return_value }
        double.foo
        double.foo(42)
        double.foo(:zing, :zang, &block)
        double.some_other_method(:doesnt_matter)

        calls = double.calls_to(:foo)

        expect(calls.size).to eq 3
        calls[0].tap do |call|
          expect(call.args).to eq []
          expect(call.block).to eq nil
        end
        calls[1].tap do |call|
          expect(call.args).to eq [42]
          expect(call.block).to eq nil
        end
        calls[2].tap do |call|
          expect(call.args).to eq [:zing, :zang]
          expect(call.block).to eq block
        end
      end

      it 'returns an empty array if the given method was never called' do
        double = described_class.new
        expect(double.calls_to(:unknown_method)).to eq []
      end
    end
  end
end
