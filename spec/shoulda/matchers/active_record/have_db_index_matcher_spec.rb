require 'spec_helper'

describe Shoulda::Matchers::ActiveRecord::HaveDbIndexMatcher do
  context 'have_db_index' do
    it 'accepts an existing index' do
      with_index_on(:age).should have_db_index(:age)
    end

    it 'rejects a nonexistent index' do
      define_model(:employee).new.should_not have_db_index(:age)
    end
  end

  context 'have_db_index with unique option' do
    it 'accepts an index of correct unique' do
      with_index_on(:ssn, :unique => true).
        should have_db_index(:ssn).unique(true)
    end

    it 'rejects an index of wrong unique' do
      with_index_on(:ssn, :unique => false).
        should_not have_db_index(:ssn).unique(true)
    end
  end

  context 'have_db_index on multiple columns' do
    it 'accepts an existing index' do
      db_connection = create_table 'geocodings' do |table|
        table.integer :geocodable_id
        table.string  :geocodable_type
      end
      db_connection.add_index :geocodings, [:geocodable_type, :geocodable_id]
      define_model_class('Geocoding').new.
        should have_db_index([:geocodable_type, :geocodable_id])
    end

    it 'rejects a nonexistent index' do
      create_table 'geocodings' do |table|
        table.integer :geocodable_id
        table.string  :geocodable_type
      end
      define_model_class('Geocoding').new.
        should_not have_db_index([:geocodable_type, :geocodable_id])
    end
  end

  it 'join columns with and when describing multiple columns' do
    have_db_index([:user_id, :post_id]).description.should =~ /on columns user_id and post_id/
  end

  it 'describes a unique index as unique' do
    have_db_index(:user_id).unique(true).description.should =~ /a unique index/
  end

  it 'describes a non-unique index as non-unique' do
    have_db_index(:user_id).unique(false).description.should =~ /a non-unique index/
  end

  it "does not display an index's uniqueness when it's not important" do
    have_db_index(:user_id).description.should_not =~ /unique/
  end

  it 'allows an IndexDefinition to have a truthy value for unique' do
    index_definition = stub('ActiveRecord::ConnectionAdapters::IndexDefinition',
      :unique => 7, :name => :age)
    matcher = have_db_index(:age).unique(true)
    matcher.stubs(:matched_index => index_definition)

    with_index_on(:age).should matcher
  end

  def with_index_on(column_name, index_options = {})
    create_table 'employees' do |table|
      table.integer column_name
    end.add_index(:employees, column_name, index_options)
    define_model_class('Employee').new
  end
end
