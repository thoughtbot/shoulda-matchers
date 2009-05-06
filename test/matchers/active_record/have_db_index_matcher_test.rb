require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class HaveDbIndexMatcherTest < ActiveSupport::TestCase # :nodoc:
  
  context "have_db_index" do
    setup do
      @matcher = have_db_index(:age)
    end

    should "accept an existing index" do
      db_connection = create_table 'superheros' do |table|
        table.integer :age
      end
      db_connection.add_index :superheros, :age
      define_model_class 'Superhero'
      assert_accepts @matcher, Superhero.new
    end
    
    should "reject a nonexistent index" do
      define_model :superhero
      assert_rejects @matcher, Superhero.new
    end
  end
  
  context "have_db_index with unique option" do
    setup do
      @matcher = have_db_index(:ssn).unique(true)
    end

    should "accept an index of correct unique" do
      db_connection = create_table 'superheros' do |table|
        table.integer :ssn
      end
      db_connection.add_index :superheros, :ssn, :unique => true
      define_model_class 'Superhero'
      assert_accepts @matcher, Superhero.new
    end
    
    should "reject an index of wrong unique" do
      db_connection = create_table 'superheros' do |table|
        table.integer :ssn
      end
      db_connection.add_index :superheros, :ssn, :unique => false
      define_model_class 'Superhero'
      assert_rejects @matcher, Superhero.new
    end
  end
  
  context "have_db_index on multiple columns" do
    setup do
      @matcher = have_db_index([:geocodable_type, :geocodable_id])
    end

    should "accept an existing index" do
      db_connection = create_table 'geocodings' do |table|
        table.integer :geocodable_id
        table.string  :geocodable_type
      end
      db_connection.add_index :geocodings, [:geocodable_type, :geocodable_id]
      define_model_class 'Geocoding'
      assert_accepts @matcher, Geocoding.new
    end
    
    should "reject a nonexistant index" do
      db_connection = create_table 'geocodings' do |table|
        table.integer :geocodable_id
        table.string  :geocodable_type
      end
      define_model_class 'Geocoding'
      assert_rejects @matcher, Geocoding.new
    end
  end

  should "join columns with and describing multiple columns" do
    assert_match /on columns user_id and post_id/,
      have_db_index([:user_id, :post_id]).description
  end

  should "describe a unique index as unique" do
    assert_match /a unique index/, have_db_index(:user_id).unique(true).description
  end

  should "describe a non-unique index as non-unique" do
    assert_match /a non-unique index/, have_db_index(:user_id).unique(false).description
  end

  should "not describe an index's uniqueness when it isn't important" do
    assert_no_match /unique/, have_db_index(:user_id).description
  end
  
end
