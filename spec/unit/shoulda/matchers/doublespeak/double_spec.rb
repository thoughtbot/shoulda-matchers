require 'unit_spec_helper'

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
        klass = create_class(a_method: 42)
        instance = klass.new
        double = described_class.new(klass, :a_method, implementation)
        args = [:any, :args]
        block = -> {}

        double.activate
        instance.a_method(*args, &block)

        expect(implementation).
          to have_received(:call).
          with(double, instance, args, block)
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
      it 'stores the arguments and block given to the method in calls' do
        double = described_class.new(:klass, :a_method, :implementation)
        calls = [
          [:any, :args], :block,
          [:more, :args]
        ]
        double.record_call(calls[0][0], calls[0][1])
        double.record_call(calls[1][0], nil)

        expect(double.calls[0].args).to eq calls[0][0]
        expect(double.calls[0].block).to eq calls[0][1]
        expect(double.calls[1].args).to eq calls[1][0]
      end
    end

    describe '#call_original_method' do
      it 'binds the stored method object to the class and calls it with the given args and block' do
        klass = create_class
        instance = klass.new
        actual_args = actual_block = method_called = nil
        expected_args = [:one, :two, :three]
        expected_block = -> { }
        double = described_class.new(klass, :a_method, :implementation)

        klass.__send__(:define_method, :a_method) do |*args, &block|
          actual_args = expected_args
          actual_block = expected_block
          method_called = true
        end

        double.activate
        double.call_original_method(instance, expected_args, expected_block)

        expect(expected_args).to eq actual_args
        expect(expected_block).to eq actual_block
        expect(method_called).to eq true
      end

      it 'does nothing if no method has been stored' do
        double = described_class.new(:klass, :a_method, :implementation)

        expect {
          double.call_original_method(:instance, [:any, :args], nil)
        }.not_to raise_error
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
