require 'doublespeak_spec_helper'

module Shoulda::Matchers::Doublespeak
  describe DoubleCollection do
    describe '#register_stub' do
      it 'calls DoubleImplementationRegistry.find correctly' do
        allow(DoubleImplementationRegistry).to receive(:find)
        double_collection = described_class.new(build_world, :klass)

        double_collection.register_stub(:a_method)

        expect(DoubleImplementationRegistry).to have_received(:find).with(:stub)
      end

      it 'calls Double.new correctly' do
        world = build_world
        allow(DoubleImplementationRegistry).
          to receive(:find).
          and_return(:implementation)
        allow(Double).to receive(:new)
        double_collection = described_class.new(world, :klass)

        double_collection.register_stub(:a_method)

        expect(Double).
          to have_received(:new).
          with(world, :klass, :a_method, :implementation)
      end

      context 'if a double has already been registered for the method' do
        it 'does not call Double.new again' do
          world = build_world
          allow(DoubleImplementationRegistry).
            to receive(:find).
            and_return(:implementation)
          allow(Double).to receive(:new)
          double_collection = described_class.new(world, :klass)

          double_collection.register_stub(:a_method)
          double_collection.register_stub(:a_method)

          expect(Double).to have_received(:new).once
        end

        it 'returns the same Double' do
          world = build_world
          allow(DoubleImplementationRegistry).
            to receive(:find).
            and_return(:implementation)
          allow(Double).to receive(:new)
          double_collection = described_class.new(world, :klass)

          double1 = double_collection.register_stub(:a_method)
          double2 = double_collection.register_stub(:a_method)

          expect(double1).to equal(double2)
        end
      end
    end

    describe '#register_proxy' do
      it 'calls DoubleImplementationRegistry.find correctly' do
        allow(DoubleImplementationRegistry).to receive(:find)
        double_collection = described_class.new(build_world, :klass)

        double_collection.register_proxy(:a_method)

        expect(DoubleImplementationRegistry).
          to have_received(:find).
          with(:proxy)
      end

      it 'calls Double.new correctly' do
        world = build_world
        allow(DoubleImplementationRegistry).
          to receive(:find).
          and_return(:implementation)
        allow(Double).to receive(:new)
        double_collection = described_class.new(world, :klass)

        double_collection.register_proxy(:a_method)

        expect(Double).
          to have_received(:new).
          with(world, :klass, :a_method, :implementation)
      end

      context 'if a double has already been registered for the method' do
        it 'does not call Double.new again' do
          world = build_world
          allow(DoubleImplementationRegistry).
            to receive(:find).
            and_return(:implementation)
          allow(Double).to receive(:new)
          double_collection = described_class.new(world, :klass)

          double_collection.register_proxy(:a_method)
          double_collection.register_proxy(:a_method)

          expect(Double).to have_received(:new).once
        end

        it 'returns the same Double' do
          world = build_world
          allow(DoubleImplementationRegistry).
            to receive(:find).
            and_return(:implementation)
          allow(Double).to receive(:new)
          double_collection = described_class.new(world, :klass)

          double1 = double_collection.register_proxy(:a_method)
          double2 = double_collection.register_proxy(:a_method)

          expect(double1).to equal(double2)
        end
      end
    end

    describe '#activate' do
      it 'replaces all registered methods with doubles' do
        klass = create_class(first_method: 1, second_method: 2)
        double_collection = described_class.new(build_world, klass)
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
        double_collection = described_class.new(build_world, klass)
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
        double_collection = described_class.new(build_world, klass)
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
        double_collection = described_class.new(build_world, klass)
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

    def build_world
      Shoulda::Matchers::Doublespeak::World.new
    end
  end
end
