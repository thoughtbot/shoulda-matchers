require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveRecord::AssociationMatchers::ModelReflection do
  it 'delegates other methods to the given Reflection object' do
    define_model(:country)
    person_model = define_model(:person, country_id: :integer) do
      belongs_to :country
    end
    delegate_reflection = person_model.reflect_on_association(:country)
    allow(delegate_reflection).to receive(:foo).and_return('bar')
    reflection = described_class.new(delegate_reflection)

    expect(reflection.foo).to eq 'bar'
  end

  describe '#associated_class' do
    it 'returns the model that the association refers to' do
      define_model(:country)
      person_model = define_model(:person, country_id: :integer) do
        belongs_to :country
      end
      delegate_reflection = person_model.reflect_on_association(:country)
      reflection = described_class.new(delegate_reflection)

      expect(reflection.associated_class).to be Country
    end
  end

  describe '#through?' do
    it 'returns true if the reflection is for a has_many :through association' do
      define_model(:city, person_id: :integer)
      define_model(:person, country_id: :integer) do
        has_many :cities
      end
      country_model = define_model(:country) do
        has_many :people
        has_many :cities, through: :people
      end
      delegate_reflection = country_model.reflect_on_association(:cities)
      reflection = described_class.new(delegate_reflection)

      expect(reflection).to be_through
    end

    it 'returns false if not' do
      define_model(:person, country_id: :integer)
      country_model = define_model(:country) do
        has_many :people
      end
      delegate_reflection = country_model.reflect_on_association(:people)
      reflection = described_class.new(delegate_reflection)

      expect(reflection).not_to be_through
    end
  end

  describe '#join_table_name' do
    context 'when the association was defined with a :join_table option' do
      it 'returns the value of the option' do
        create_table :foos, id: false do |t|
          t.integer :person_id
          t.integer :country_id
        end
        define_model(:person, country_id: :integer)
        country_model = define_model(:country) do
          has_and_belongs_to_many :people, join_table: 'foos'
        end
        delegate_reflection = country_model.reflect_on_association(:people)
        reflection = described_class.new(delegate_reflection)

        expect(reflection.join_table_name).to eq 'foos'
      end
    end

    context 'when the association was not defined with :join_table' do
      it 'returns the default join_table that ActiveRecord generates' do
        define_model(:person, country_id: :integer)
        country_model = define_model(:country) do
          has_and_belongs_to_many :people
        end
        delegate_reflection = country_model.reflect_on_association(:people)
        reflection = described_class.new(delegate_reflection)

        expect(reflection.join_table_name).to eq 'countries_people'
      end
    end
  end

  describe '#association_relation' do
    context 'when the reflection object has a #scope method' do
      context 'when the scope is a block' do
        it 'executes the block in the context of an empty scope' do
          define_model(:country, mood: :string)
          person_model = define_model(:person, country_id: :integer) do
            belongs_to :country, -> { where(mood: 'nice') }
          end
          delegate_reflection = person_model.reflect_on_association(:country)
          reflection = described_class.new(delegate_reflection)

          actual_sql = reflection.association_relation.to_sql
          expected_sql = Country.where(mood: 'nice').to_sql
          expect(actual_sql).to eq expected_sql
        end
      end

      context 'when the scope is nil' do
        it 'returns an empty scope' do
          define_model(:country)
          person_model = define_model(:person, country_id: :integer) do
            belongs_to :country
          end
          delegate_reflection = person_model.reflect_on_association(:country)
          reflection = described_class.new(delegate_reflection)

          actual_sql = reflection.association_relation.to_sql
          expected_sql = Country.all.to_sql
          expect(actual_sql).to eq expected_sql
        end
      end
    end
  end
end
