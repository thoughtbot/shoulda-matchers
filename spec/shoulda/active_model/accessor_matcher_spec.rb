require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::AccessorMatcher do
	context "an attribute defined through attr_accessor" do
		let(:model) do
			define_class(:example) do
				attr_accessor :attr
			end.new
		end

		it "should have writer and reader methods defined" do
			model.should have_accessor(:attr)
		end
	end

	context "an attribute defined through attr_writer" do
		let(:model) do
			define_class(:example) do
				attr_writer :attr
			end.new
		end

		it "should have a writer method defined" do
			model.should have_writer(:attr)
		end

		it "should not have a reader method defined" do
			model.should_not have_reader(:attr)
		end
	end

	context "an attribute defined through attr_reader" do
		let(:model) do
			define_class(:example) do
				attr_reader :attr
			end.new
		end

		it "should have a reader method defined" do
			model.should have_reader(:attr)
		end

		it "should not have a writer method defined" do
			model.should_not have_writer(:attr)
		end
	end

	context "an undefined attribute" do
		let(:model) do
			define_class(:example).new
		end
		let(:reader_matcher) {have_reader(:attr)}
		let(:writer_matcher) {have_writer(:attr)}

		it "should fail reader match with error" do
			reader_matcher.matches?(model).should be_false
			reader_matcher.failure_message.should == "Example does not have method 'attr'"
		end

		it "should fail writer match with error" do
			writer_matcher.matches?(model).should be_false
			writer_matcher.failure_message.should == "Example does not have method 'attr='"
		end
	end
end