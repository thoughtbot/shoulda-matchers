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

    it "accepts the correct number of queries when there is a single query" do
      @parent.should query_the_database(1.times).when_calling(:count)
    end

    it "accepts any number of queries when no number is specified" do
      @parent.should query_the_database.when_calling(:count)
    end

    it "rejects any number of queries when no number is specified" do
      @parent.should_not query_the_database.when_calling(:to_s)
    end

    it "accepts the correct number of queries when there are two queries" do
      nonsense = lambda do
        @parent.create.kittens.create
      end
      nonsense.should query_the_database(2.times).when_calling(:call)
    end

    it "rejects the wrong number of queries" do
      @parent.should_not query_the_database(10.times).when_calling(:count)
    end

    it "accepts fewer than the specified maximum" do
      @parent.should query_the_database(5.times).or_less.when_calling(:count)
    end

    it "passes arguments to the method to examine" do
      model = stub("Model", :count => nil)
      model.expects(:count).with("arguments")
      model.should_not query_the_database.when_calling(:count).with("arguments")
    end
  else
    it "should raise an exception on Rails < 3.1" do
      model = define_model(:litter)
      lambda do
        model.should query_the_database(1.times).when_calling(:count)
      end.should raise_exception(RuntimeError, "Rails 3.1 or greater is required")
    end
  end
end
