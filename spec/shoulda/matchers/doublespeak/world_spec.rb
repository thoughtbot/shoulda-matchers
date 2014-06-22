require 'spec_helper'

module Shoulda::Matchers::Doublespeak
  describe World do
    describe '#double_collection_for' do
      it 'calls DoubleCollection.new once with the given class' do
        DoubleCollection.expects(:new).with(:klass).returns(:klass).once
        world = described_class.new
        world.double_collection_for(:klass)
        world.double_collection_for(:klass)
      end

      it 'returns the created DoubleCollection' do
        double_collection = Object.new
        DoubleCollection.stubs(:new).with(:klass).returns(double_collection)
        world = described_class.new
        expect(world.double_collection_for(:klass)).to be double_collection
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
        world.double_collection_for(:klass1)
        world.double_collection_for(:klass2)
        world.double_collection_for(:klass3)

        world.with_doubles_activated { block_called = true }

        expect(block_called).to eq true
      end

      it 'still makes sure to uninstall all doubles even if the block raises an error' do
        double_collection = stub()
        double_collection.stubs(:activate)
        double_collection.expects(:deactivate)

        world = described_class.new

        DoubleCollection.stubs(:new).returns(double_collection)
        world.double_collection_for(:klass)

        begin
          world.with_doubles_activated { raise 'error' }
        rescue RuntimeError
        end
      end
    end
  end
end
