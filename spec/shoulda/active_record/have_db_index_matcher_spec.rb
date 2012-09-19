require 'spec_helper'

describe Shoulda::Matchers::ActiveRecord::HaveDbIndexMatcher do
  context "have_db_index" do
    before do
      @matcher = have_db_index(:age)
    end

    it "should accept an existing index" do
      db_connection = create_table 'superheros' do |table|
        table.integer :age
      end
      db_connection.add_index :superheros, :age
      define_model_class 'Superhero'
      Superhero.new.should @matcher
    end

    it "should reject a nonexistent index" do
      define_model :superhero
      Superhero.new.should_not @matcher
    end
  end

  context "have_db_index with unique option" do
    before do
      @matcher = have_db_index(:ssn).unique(true)
    end

    it "should accept an index of correct unique" do
      db_connection = create_table 'superheros' do |table|
        table.integer :ssn
      end
      db_connection.add_index :superheros, :ssn, :unique => true
      define_model_class 'Superhero'
      Superhero.new.should @matcher
    end

    it "should reject an index of wrong unique" do
      db_connection = create_table 'superheros' do |table|
        table.integer :ssn
      end
      db_connection.add_index :superheros, :ssn, :unique => false
      define_model_class 'Superhero'
      Superhero.new.should_not @matcher
    end
  end

  context "have_db_index on multiple columns" do
    before do
      @matcher = have_db_index([:geocodable_type, :geocodable_id])
    end

    it "should accept an existing index" do
      db_connection = create_table 'geocodings' do |table|
        table.integer :geocodable_id
        table.string  :geocodable_type
      end
      db_connection.add_index :geocodings, [:geocodable_type, :geocodable_id]
      define_model_class 'Geocoding'
      Geocoding.new.should @matcher
    end

    it "should reject a nonexistant index" do
      db_connection = create_table 'geocodings' do |table|
        table.integer :geocodable_id
        table.string  :geocodable_type
      end
      define_model_class 'Geocoding'
      Geocoding.new.should_not @matcher
    end
  end

  it "should join columns with and describing multiple columns" do
    have_db_index([:user_id, :post_id]).description.should =~ /on columns user_id and post_id/
  end

  it "should context a unique index as unique" do
    have_db_index(:user_id).unique(true).description.should =~ /a unique index/
  end

  it "should context a non-unique index as non-unique" do
    have_db_index(:user_id).unique(false).description.should =~ /a non-unique index/
  end

  it "should not context an index's uniqueness when it isn't important" do
    have_db_index(:user_id).description.should_not =~ /unique/
  end

  it "allows an IndexDefinition to have a truthy value for unique" do
    db_connection = create_table 'superheros' do |table|
      table.integer :age
    end
    db_connection.add_index :superheros, :age
    define_model_class 'Superhero'

    @matcher = have_db_index(:age).unique(true)

    index_definition = stub("ActiveRecord::ConnectionAdapters::IndexDefinition",
                            :unique => 7,
                            :name => :age)
    @matcher.stubs(:matched_index => index_definition)

    Superhero.new.should @matcher
  end
end
