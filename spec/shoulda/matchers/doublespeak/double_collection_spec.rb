require 'spec_helper'

module Shoulda::Matchers::Doublespeak
  describe DoubleCollection do
    describe '#stub' do
      it 'calls DoubleImplementationRegistry.find correctly' do
        double_collection = described_class.new(:klass)
        DoubleImplementationRegistry.expects(:find).with(:stub)
        double_collection.stub(:a_method)
      end

      it 'calls Double.new correctly' do
        DoubleImplementationRegistry.stubs(:find).returns(:implementation)
        double_collection = described_class.new(:klass)
        Double.expects(:new).with(:klass, :a_method, :implementation)
        double_collection.stub(:a_method)
      end
    end

    describe '#proxy' do
      it 'calls DoubleImplementationRegistry.find correctly' do
        double_collection = described_class.new(:klass)
        DoubleImplementationRegistry.expects(:find).with(:proxy)
        double_collection.proxy(:a_method)
      end

      it 'calls Double.new correctly' do
        DoubleImplementationRegistry.stubs(:find).returns(:implementation)
        double_collection = described_class.new(:klass)
        Double.expects(:new).with(:klass, :a_method, :implementation)
        double_collection.proxy(:a_method)
      end
    end

    describe '#install_all' do
      it 'replaces all registered methods with doubles' do
        klass = create_class(first_method: 1, second_method: 2)
        double_collection = described_class.new(klass)
        double_collection.stub(:first_method)
        double_collection.stub(:second_method)

        double_collection.install_all

        instance = klass.new
        expect(instance.first_method).to eq nil
        expect(instance.second_method).to eq nil
      end
    end

    describe '#uninstall_all' do
      it 'restores the original methods that were doubled' do
        klass = create_class(first_method: 1, second_method: 2)
        double_collection = described_class.new(klass)
        double_collection.stub(:first_method)
        double_collection.stub(:second_method)

        double_collection.install_all
        double_collection.uninstall_all

        instance = klass.new
        expect(instance.first_method).to eq 1
        expect(instance.second_method).to eq 2
      end
    end

    describe '#installing_all' do
      it 'installs doubles inside the block and uninstalls them after' do
        klass = create_class(first_method: 1, second_method: 2)
        double_collection = described_class.new(klass)
        double_collection.stub(:first_method)
        double_collection.stub(:second_method)
        instance = klass.new

        expect(instance.first_method).to eq 1
        expect(instance.second_method).to eq 2

        double_collection.installing_all do
          expect(instance.first_method).to eq nil
          expect(instance.second_method).to eq nil
        end

        expect(instance.first_method).to eq 1
        expect(instance.second_method).to eq 2
      end
    end

    describe '#calls_on' do
      it 'returns all calls to the given method' do
        klass = create_class(a_method: nil)
        double_collection = described_class.new(klass)
        double_collection.stub(:a_method)
        double_collection.install_all

        actual_calls = [
          { args: [:some, :args, :here] },
          { args: [:some, :args], block: -> { :whatever } }
        ]
        instance = klass.new
        instance.a_method(*actual_calls[0][:args])
        instance.a_method(*actual_calls[1][:args], &actual_calls[1][:block])

        calls = double_collection.calls_on(:a_method)
        expect(calls[0].args).to eq actual_calls[0][:args]
        expect(calls[1].args).to eq actual_calls[1][:args]
        expect(calls[1].block).to eq actual_calls[1][:block]
      end

      it 'returns an empty array if the method has never been doubled' do
        klass = create_class
        double_collection = described_class.new(klass)
        expect(double_collection.calls_on(:non_existent_method)).to eq []
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
