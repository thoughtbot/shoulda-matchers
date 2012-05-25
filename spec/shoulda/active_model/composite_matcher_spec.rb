require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::CompositeMatcher do
  context '#add_matcher' do
    it 'adds a matcher to match against later' do
      sub_matcher = mock('sub matcher', :matches? => true)
      subject = stub('subject')
      composite_matcher = Shoulda::Matchers::ActiveModel::CompositeMatcher.new
      composite_matcher.add_matcher(sub_matcher)
      composite_matcher.matches?(subject)
      sub_matcher.should have_received(:matches?).with(subject)
    end
  end

  context '#description' do
    it 'is a combination of descriptions from the sub_matchers' do
      first_sub_matcher = mock('first sub matchers', :description => 'First Matcher')
      second_sub_matcher = mock('second sub matchers', :description => 'Second Matcher')
      composite_matcher = Shoulda::Matchers::ActiveModel::CompositeMatcher.new
      composite_matcher.add_matcher(first_sub_matcher)
      composite_matcher.add_matcher(second_sub_matcher)
      composite_matcher.description.should == "First Matcher Second Matcher"
    end
  end

  context '#matches?' do
    it 'returns true if all sub matchers match' do
      sub_matcher = stub('sub matcher', :matches? => true)
      subject = stub('subject')
      composite_matcher = Shoulda::Matchers::ActiveModel::CompositeMatcher.new
      2.times { composite_matcher.add_matcher(sub_matcher) }
      composite_matcher.matches?(subject).should be_true
    end

    it 'returns false if any sub matcher does not match' do
      matching_sub_matcher = stub('sub matcher', :matches? => true)
      not_matching_sub_matcher = stub('sub matcher', :matches? => false)
      subject = stub('subject')
      composite_matcher = Shoulda::Matchers::ActiveModel::CompositeMatcher.new
      composite_matcher.add_matcher(matching_sub_matcher)
      composite_matcher.add_matcher(not_matching_sub_matcher)
      composite_matcher.matches?(subject).should be_false
    end
  end
end
