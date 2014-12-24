require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveRecord::HaveDbIndexMatcher, type: :model do
  context 'have_db_index' do
    it 'accepts an existing index' do
      expect(with_index_on(:age)).to have_db_index(:age)
    end

    it 'rejects a nonexistent index' do
      expect(define_model(:employee).new).not_to have_db_index(:age)
    end
  end

  context 'have_db_index with unique option' do
    it 'accepts an index of correct unique' do
      expect(with_index_on(:ssn, unique: true)).
        to have_db_index(:ssn).unique(true)
    end

    it 'rejects an index of wrong unique' do
      expect(with_index_on(:ssn, unique: false)).
        not_to have_db_index(:ssn).unique(true)
    end
  end

  context 'have_db_index on multiple columns' do
    it 'accepts an existing index' do
      db_connection = create_table 'geocodings' do |table|
        table.integer :geocodable_id
        table.string  :geocodable_type
      end
      db_connection.add_index :geocodings, [:geocodable_type, :geocodable_id]
      expect(define_model_class('Geocoding').new).
        to have_db_index([:geocodable_type, :geocodable_id])
    end

    it 'rejects a nonexistent index' do
      create_table 'geocodings' do |table|
        table.integer :geocodable_id
        table.string  :geocodable_type
      end
      expect(define_model_class('Geocoding').new).
        not_to have_db_index([:geocodable_type, :geocodable_id])
    end
  end

  it 'join columns with and when describing multiple columns' do
    expect(have_db_index([:user_id, :post_id]).description).to match(/on columns user_id and post_id/)
  end

  it 'describes a unique index as unique' do
    expect(have_db_index(:user_id).unique(true).description).to match(/a unique index/)
  end

  it 'describes a unique index as unique when no argument is given' do
    expect(have_db_index(:user_id).unique.description).to match(/a unique index/)
  end

  it 'describes a non-unique index as non-unique' do
    expect(have_db_index(:user_id).unique(false).description).to match(/a non-unique index/)
  end

  it "does not display an index's uniqueness when it's not important" do
    expect(have_db_index(:user_id).description).not_to match(/unique/)
  end

  it 'allows an IndexDefinition to have a truthy value for unique' do
    index_definition = double(
      'ActiveRecord::ConnectionAdapters::IndexDefinition',
      unique: 7,
      name: :age
    )
    matcher = have_db_index(:age).unique(true)
    allow(matcher).to receive(:matched_index).and_return(index_definition)

    expect(with_index_on(:age)).to matcher
  end

  def with_index_on(column_name, index_options = {})
    create_table 'employees' do |table|
      table.integer column_name
    end.add_index(:employees, column_name, index_options)
    define_model_class('Employee').new
  end
end
