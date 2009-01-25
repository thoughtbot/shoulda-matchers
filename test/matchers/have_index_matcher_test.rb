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
  
end
