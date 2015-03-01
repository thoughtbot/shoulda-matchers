require 'doublespeak_spec_helper'

module Shoulda::Matchers::Doublespeak
  describe Double do
    describe '#to_return' do
      it 'tells its implementation to call the given block' do
        sent_block = -> { }
        actual_block = nil
        implementation = build_implementation
        implementation.singleton_class.__send__(:undef_method, :returns)
        implementation.singleton_class.__send__(:define_method, :returns) do |&block|
          actual_block = block
        end
        double = described_class.new(:klass, :a_method, implementation)
        double.to_return(&sent_block)
        expect(actual_block).to eq sent_block
      end

      it 'tells its implementation to return the given value' do
        implementation = build_implementation
        double = described_class.new(:klass, :a_method, implementation)
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
        double = described_class.new(:klass, :a_method, implementation)
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
        double = described_class.new(klass, method_name, implementation)
        args = [:any, :args]
        block = -> {}
        call = MethodCall.new(
          double: double,
          object: instance,
          method_name: method_name,
          args: args,
          block: block
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
        implementation = build_implementation
        klass = create_class(a_method: 42)
        instance = klass.new
        double = described_class.new(klass, :a_method, implementation)

        double.activate
        double.deactivate
        expect(instance.a_method).to eq 42
      end

      it 'still restores the original method if #activate was called twice' do
        implementation = build_implementation
        klass = create_class(a_method: 42)
        instance = klass.new
        double = described_class.new(klass, :a_method, implementation)

        double.activate
        double.activate
        double.deactivate
        expect(instance.a_method).to eq 42
      end

      it 'does nothing if the method has not been doubled' do
        implementation = build_implementation
        klass = create_class(a_method: 42)
        instance = klass.new
        double = described_class.new(klass, :a_method, implementation)

        double.deactivate
        expect(instance.a_method).to eq 42
      end
    end

    describe '#record_call' do
      it 'adds the given call to the list of calls' do
        double = described_class.new(:a_klass, :a_method, :an_implementation)
        double.record_call(:some_call)
        expect(double.calls.last).to eq :some_call
      end
    end

    describe '#call_original_method' do
      it 'binds the stored method object to the given object and calls it with the given args and block' do
        klass = create_class
        instance = klass.new
        actual_args = actual_block = method_called = nil
        expected_args = [:one, :two, :three]
        expected_block = -> { }
        call = double('call',
          object: instance,
          args: expected_args,
          block: expected_block
        )
        double = described_class.new(klass, :a_method, :an_implementation)

        klass.__send__(:define_method, :a_method) do |*args, &block|
          actual_args = expected_args
          actual_block = expected_block
          method_called = true
        end

        double.activate
        double.call_original_method(call)

        expect(expected_args).to eq actual_args
        expect(expected_block).to eq actual_block
        expect(method_called).to eq true
      end

      it 'does nothing if no method has been stored' do
        double = described_class.new(:klass, :a_method, :an_implementation)
        expect { double.call_original_method(:a_call) }.not_to raise_error
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
  end
end
