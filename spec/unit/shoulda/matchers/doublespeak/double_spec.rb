require 'doublespeak_spec_helper'

module Shoulda::Matchers::Doublespeak
  describe Double do
    describe 'initializer' do
      context 'if doubles are currently activated on the world level' do
        it 'immediately activates the new Double' do
          world = build_world(doubles_activated?: true)
          klass = create_class(a_method_name: nil)
          implementation = build_implementation

          double = described_class.new(world, klass, :a_method_name, implementation)

          expect(double).to be_activated
        end
      end
    end

    describe '#to_return' do
      it 'tells its implementation to call the given block' do
        sent_block = -> { }
        actual_block = nil
        implementation = build_implementation
        implementation.singleton_class.__send__(:undef_method, :returns)
        implementation.singleton_class.__send__(:define_method, :returns) do |&block|
          actual_block = block
        end
        double = described_class.new(
          build_world,
          :klass,
          :a_method,
          implementation
        )
        double.to_return(&sent_block)
        expect(actual_block).to eq sent_block
      end

      it 'tells its implementation to return the given value' do
        implementation = build_implementation
        double = described_class.new(
          build_world,
          :klass,
          :a_method,
          implementation
        )
        double.to_return(:implementation)

        expect(implementation).to have_received(:returns).with(:implementation)
      end

      it 'prefers a block over a non-block' do
        sent_block = -> { }
        actual_block = nil
        implementation = build_implementation
        implementation.singleton_class.__send__(:undef_method, :returns)
        implementation.singleton_class.__send__(:define_method, :returns) do |&block|
          actual_block = block
        end
        double = described_class.new(
          build_world,
          :klass,
          :a_method,
          implementation
        )
        double.to_return(:value, &sent_block)
        expect(actual_block).to eq sent_block
      end
    end

    describe '#activate' do
      it 'replaces the method with an implementation' do
        implementation = build_implementation
        method_name = :a_method
        klass = create_class(method_name => :some_return_value)
        instance = klass.new
        double = described_class.new(
          build_world,
          klass,
          method_name,
          implementation
        )
        args = [:any, :args]
        block = -> {}
        call = MethodCall.new(
          double: double,
          object: instance,
          method_name: method_name,
          args: args,
          block: block,
          caller: :some_caller
        )

        double.activate
        instance.__send__(method_name, *args, &block)

        expect(implementation).
          to have_received(:call).
          with(call)
      end
    end

    describe '#deactivate' do
      it 'restores the original method after being doubled' do
        klass = create_class(a_method: 42)
        world = build_world(
          original_method_for: klass.instance_method(:a_method)
        )
        instance = klass.new
        double = described_class.new(
          world,
          klass,
          :a_method,
          build_implementation
        )

        double.activate
        double.deactivate
        expect(instance.a_method).to eq 42
      end

      it 'still restores the original method if #activate was called twice' do
        method_name = :a_method
        klass = create_class(method_name => 42)
        world = build_world(
          original_method_for: klass.instance_method(:a_method)
        )
        instance = klass.new
        double = described_class.new(
          world,
          klass,
          :a_method,
          build_implementation
        )

        double.activate
        double.activate
        double.deactivate
        expect(instance.a_method).to eq 42
      end

      it 'does nothing if the method has not been doubled' do
        klass = create_class(a_method: 42)
        instance = klass.new
        double = described_class.new(
          build_world,
          klass,
          :a_method,
          build_implementation
        )

        double.deactivate
        expect(instance.a_method).to eq 42
      end
    end

    describe '#record_call' do
      it 'adds the given call to the list of calls' do
        double = described_class.new(
          build_world,
          :a_klass,
          :a_method,
          :an_implementation
        )
        double.record_call(:some_call)
        expect(double.calls.last).to eq :some_call
      end
    end

    describe '#call_original_method' do
      it 'binds the stored method object to the given object and calls it with the given args and block' do
        expected_args = [:one, :two, :three]
        expected_block = -> { }
        actual_args = actual_block = method_called = nil
        method_name = :a_method
        klass = create_class
        klass.__send__(:define_method, method_name) do |*args, &block|
          actual_args = args
          actual_block = block
          method_called = true
        end
        world = build_world(
          original_method_for: klass.instance_method(method_name)
        )
        instance = klass.new
        call = double('call',
          object: instance,
          method_name: method_name,
          args: expected_args,
          block: expected_block
        )
        double = described_class.new(
          world,
          klass,
          method_name,
          :an_implementation
        )

        double.activate
        double.call_original_method(call)

        expect(actual_args).to eq expected_args
        expect(actual_block).to eq expected_block
        expect(method_called).to eq true
      end

      it 'does nothing if no method has been stored' do
        method_name = :a_method
        world = build_world(original_method_for: nil)
        call = double('call', method_name: method_name)
        double = described_class.new(
          world,
          :klass,
          method_name,
          :an_implementation
        )
        expect { double.call_original_method(call) }.not_to raise_error
      end

      it 'does not store the original method multiple times when a method is doubled multiple times' do
        world = Shoulda::Matchers::Doublespeak::World.new
        klass = create_class(a_method: :some_return_value)
        method_name = :a_method
        doubles = 2.times.map do
          described_class.new(
            world,
            klass,
            method_name,
            build_implementation
          )
        end
        instance = klass.new

        doubles[0].activate

        was_called = false
        klass.__send__(:define_method, method_name) do
          was_called = true
        end

        doubles[1].activate

        doubles.each(&:deactivate)

        instance.__send__(method_name)

        expect(was_called).to be false
      end
    end

    def create_class(methods = {})
      Class.new.tap do |klass|
        methods.each do |name, value|
          klass.__send__(:define_method, name) { |*args| value }
        end
      end
    end

    def build_implementation
      double('implementation', returns: nil, call: nil)
    end

    def build_world(methods = {})
      defaults = {
        original_method_for: nil,
        store_original_method_for: nil,
        doubles_activated?: nil
      }
      double('world', defaults.merge(methods))
    end
  end
end
