require 'spec_helper'

module Shoulda::Matchers::Doublespeak
  describe DoubleCollection do
    describe '#register_stub' do
      it 'calls DoubleImplementationRegistry.find correctly' do
        double_collection = described_class.new(:klass)
        DoubleImplementationRegistry.expects(:find).with(:stub)
        double_collection.register_stub(:a_method)
      end

      it 'calls Double.new correctly' do
        DoubleImplementationRegistry.stubs(:find).returns(:implementation)
        double_collection = described_class.new(:klass)
        Double.expects(:new).with(:klass, :a_method, :implementation)
        double_collection.register_stub(:a_method)
      end
    end

    describe '#register_proxy' do
      it 'calls DoubleImplementationRegistry.find correctly' do
        double_collection = described_class.new(:klass)
        DoubleImplementationRegistry.expects(:find).with(:proxy)
        double_collection.register_proxy(:a_method)
      end

      it 'calls Double.new correctly' do
        DoubleImplementationRegistry.stubs(:find).returns(:implementation)
        double_collection = described_class.new(:klass)
        Double.expects(:new).with(:klass, :a_method, :implementation)
        double_collection.register_proxy(:a_method)
      end
    end

    describe '#activate' do
      it 'replaces all registered methods with doubles' do
        klass = create_class(first_method: 1, second_method: 2)
        double_collection = described_class.new(klass)
        double_collection.register_stub(:first_method)
        double_collection.register_stub(:second_method)

        double_collection.activate

        instance = klass.new
        expect(instance.first_method).to eq nil
        expect(instance.second_method).to eq nil
      end
    end

    describe '#deactivate' do
      it 'restores the original methods that were doubled' do
        klass = create_class(first_method: 1, second_method: 2)
        double_collection = described_class.new(klass)
        double_collection.register_stub(:first_method)
        double_collection.register_stub(:second_method)

        double_collection.activate
        double_collection.deactivate

        instance = klass.new
        expect(instance.first_method).to eq 1
        expect(instance.second_method).to eq 2
      end
    end

    describe '#calls_to' do
      it 'returns all calls to the given method' do
        klass = create_class(a_method: nil)
        double_collection = described_class.new(klass)
        double_collection.register_stub(:a_method)
        double_collection.activate

        actual_calls = [
          { args: [:some, :args, :here] },
          { args: [:some, :args], block: -> { :whatever } }
        ]
        instance = klass.new
        instance.a_method(*actual_calls[0][:args])
        instance.a_method(*actual_calls[1][:args], &actual_calls[1][:block])

        calls = double_collection.calls_to(:a_method)
        expect(calls[0].args).to eq actual_calls[0][:args]
        expect(calls[1].args).to eq actual_calls[1][:args]
        expect(calls[1].block).to eq actual_calls[1][:block]
      end

      it 'returns an empty array if the method has never been doubled' do
        klass = create_class
        double_collection = described_class.new(klass)
        expect(double_collection.calls_to(:non_existent_method)).to eq []
      end
    end

    def create_class(methods = {})
      Class.new.tap do |klass|
        methods.each do |name, value|
          klass.__send__(:define_method, name) { |*args| value }
        end
      end
    end
  end
end
