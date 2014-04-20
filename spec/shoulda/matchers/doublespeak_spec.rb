require 'spec_helper'

module Shoulda::Matchers
  describe Doublespeak do
    describe '.register_double_collection' do
      it 'delegates to its world' do
        Doublespeak.world.expects(:register_double_collection).with(:klass)
        described_class.register_double_collection(:klass)
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
