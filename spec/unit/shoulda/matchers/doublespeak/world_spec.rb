require 'doublespeak_spec_helper'

module Shoulda::Matchers::Doublespeak
  describe World do
    describe '#double_collection_for' do
      it 'calls DoubleCollection.new once with the given class' do
        allow(DoubleCollection).to receive(:new).and_return(:klass)
        world = described_class.new

        world.double_collection_for(:klass)
        world.double_collection_for(:klass)

        expect(DoubleCollection).
          to have_received(:new).
          with(world, :klass).
          once
      end

      it 'returns the created DoubleCollection' do
        world = described_class.new
        double_collection = build_double_collection
        allow(DoubleCollection).
          to receive(:new).
          with(world, :klass).
          and_return(double_collection)

        expect(world.double_collection_for(:klass)).to be double_collection
      end
    end

    describe '#with_doubles_activated' do
      it 'installs all doubles, yields the block, then uninstalls them all' do
        block_called = false
        double_collections = Array.new(3) { build_double_collection }
        double_collections.each do |double_collection|
          allow(double_collection).to receive(:activate).ordered
        end
        double_collections.each do |double_collection|
          allow(double_collection).to receive(:deactivate).ordered
        end
        klasses = Array.new(3) { |i| "Klass #{i}" }
        world = described_class.new
        double_collections.zip(klasses).each do |double_collection, klass|
          allow(DoubleCollection).
            to receive(:new).
            with(world, klass).
            and_return(double_collection)
          world.double_collection_for(klass)
        end

        world.with_doubles_activated { block_called = true }

        expect(block_called).to eq true

        double_collections.each do |double_collection|
          expect(double_collection).to have_received(:activate)
          expect(double_collection).to have_received(:deactivate)
        end
      end

      it 'still makes sure to uninstall all doubles even if the block raises an error' do
        double_collection = build_double_collection
        allow(DoubleCollection).to receive(:new).and_return(double_collection)
        world = described_class.new
        world.double_collection_for(:klass)

        begin
          world.with_doubles_activated { raise 'error' }
        rescue RuntimeError
        end

        expect(double_collection).to have_received(:deactivate)
      end
    end

    def build_double_collection
      double('double_collection', activate: nil, deactivate: nil)
    end
  end
end
