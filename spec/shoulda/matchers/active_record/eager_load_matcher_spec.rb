require 'spec_helper'

describe Shoulda::Matchers::ActiveRecord::EagerLoadMatcher do
  context 'with constant queries' do
    it 'passes' do
      define_parent_model_with_children

      expect { Parent.includes(:children).map(&:children).flatten.map(&:name) }.
        to eager_load { Parent.create!.children.create!(name: 'name') }
    end
  end

  context 'with linear queries' do
    it 'fails' do
      define_parent_model_with_children

      expect {
        expect { Parent.all.map(&:children).flatten.map(&:name) }.
          to eager_load { Parent.create!.children.create!(name: 'name') }
      }.to raise_error(
        RSpec::Expectations::ExpectationNotMetError,
        /SELECT "parents"\.\*.*SELECT "children"\.\*/m
      )
    end
  end

  def define_parent_model_with_children
    define_model(:parent) do
      has_many :children
    end

    define_model(:child, name: :string, parent_id: :integer) do
      attr_accessible :name
      belongs_to :parent
    end
  end
end
