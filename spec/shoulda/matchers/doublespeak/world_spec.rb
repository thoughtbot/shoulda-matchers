require 'spec_helper'

module Shoulda::Matchers::Doublespeak
  describe World do
    describe '#register_double_collection' do
      it 'calls DoubleCollection.new with the given class' do
        DoubleCollection.expects(:new).with(:klass)
        world = described_class.new
        world.register_double_collection(:klass)
      end

      it 'returns the newly created DoubleCollection' do
        double_collection = Object.new
        DoubleCollection.stubs(:new).with(:klass).returns(double_collection)
        world = described_class.new
        expect(world.register_double_collection(:klass)).to be double_collection
      end
    end

    describe '#with_doubles_activated' do
      it 'installs all doubles, yields the block, then uninstalls them all' do
        block_called = false

        double_collections = Array.new(3) do
          stub.tap do |double_collection|
            sequence = sequence('with_doubles_activated')
            double_collection.expects(:activate).in_sequence(sequence)
            double_collection.expects(:deactivate).in_sequence(sequence)
          end
        end

        world = described_class.new

        DoubleCollection.stubs(:new).
          with(:klass1).
          returns(double_collections[0])
        DoubleCollection.stubs(:new).
          with(:klass2).
          returns(double_collections[1])
        DoubleCollection.stubs(:new).
          with(:klass3).
          returns(double_collections[2])
        world.register_double_collection(:klass1)
        world.register_double_collection(:klass2)
        world.register_double_collection(:klass3)

        world.with_doubles_activated { block_called = true }

        expect(block_called).to eq true
      end

      it 'still makes sure to uninstall all doubles even if the block raises an error' do
        double_collection = stub()
        double_collection.stubs(:activate)
        double_collection.expects(:deactivate)

        world = described_class.new

        DoubleCollection.stubs(:new).returns(double_collection)
        world.register_double_collection(:klass)

        begin
          world.with_doubles_activated { raise 'error' }
        rescue RuntimeError
        end
      end

      it 'does not allow multiple DoubleCollections to be registered that represent the same class' do
        double_collections = [stub, stub]
        sequence = sequence('with_doubles_activated')
        double_collections[0].expects(:activate).never
        double_collections[0].expects(:deactivate).never
        double_collections[1].expects(:activate).in_sequence(sequence)
        double_collections[1].expects(:deactivate).in_sequence(sequence)

        world = described_class.new

        DoubleCollection.stubs(:new).
          returns(double_collections[0]).then.
          returns(double_collections[1])
        world.register_double_collection(:klass1)
        world.register_double_collection(:klass1)

        world.with_doubles_activated { }
      end
    end
  end
end
