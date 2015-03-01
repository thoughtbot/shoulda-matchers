require 'doublespeak_spec_helper'

module Shoulda::Matchers
  describe Doublespeak do
    describe '.double_collection_for' do
      it 'delegates to its world' do
        allow(Doublespeak.world).to receive(:double_collection_for)

        described_class.double_collection_for(:klass)

        expect(Doublespeak.world).
          to have_received(:double_collection_for).
          with(:klass)
      end
    end

    describe '.with_doubles_activated' do
      it 'delegates to its world' do
        allow(Doublespeak.world).to receive(:with_doubles_activated)

        described_class.with_doubles_activated

        expect(Doublespeak.world).to have_received(:with_doubles_activated)
      end
    end
  end
end
