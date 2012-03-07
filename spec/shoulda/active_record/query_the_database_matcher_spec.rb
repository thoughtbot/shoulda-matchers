require 'spec_helper'

describe Shoulda::Matchers::ActiveRecord::QueryTheDatabaseMatcher do

  if ::ActiveRecord::VERSION::MAJOR == 3 && ::ActiveRecord::VERSION::MINOR >= 1

    before do
      @parent = define_model :litter do
        has_many :kittens
      end
      @child = define_model :kitten, :litter_id => :integer do
        belongs_to :litter
      end
    end

    it "should accept the correct number of queries when there is a single query" do
      @parent.should query_the_database(1.times).when_calling(:count)
    end

    it "should accept the correct number of queries when there are two queries" do
      nonsense = lambda do
        @parent.create.kittens.create
      end
      nonsense.should query_the_database(2.times).when_calling(:call)
    end

    it "should reject the wrong number of queries" do
      @parent.should_not query_the_database(10.times).when_calling(:count)
    end

    it "should accept fewer than the required count" do
      @parent.should query_the_database(5.times).or_less.when_calling(:count)
    end

    it "should pass arguments to the method to examine" do
      model = Class.new do
        def self.count(arguments)
          arguments.should == "arguments"
        end
      end
      model.should_not query_the_database.when_calling(:count).with("arguments")
    end

  end

end
