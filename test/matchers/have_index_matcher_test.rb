require File.join(File.dirname(__FILE__), '..', 'test_helper')

class HaveIndexMatcherTest < Test::Unit::TestCase # :nodoc:
  
  context "have_index" do
    setup do
      @matcher = have_index(:age)
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
  
  context "have_index with unique option" do
    setup do
      @matcher = have_index(:ssn).unique(true)
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
  
  context "have_index on multiple columns" do
    setup do
      @matcher = have_index([:geocodable_type, :geocodable_id])
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
  
end
