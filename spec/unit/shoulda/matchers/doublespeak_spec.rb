require 'spec_helper'

module Shoulda::Matchers
  describe Doublespeak do
    describe '.double_collection_for' do
      it 'delegates to its world' do
        Doublespeak.world.expects(:double_collection_for).with(:klass)
        described_class.double_collection_for(:klass)
      end
    end

    describe '.with_doubles_activated' do
      it 'delegates to its world' do
        Doublespeak.world.expects(:with_doubles_activated)
        described_class.with_doubles_activated
      end
    end
  end
end
