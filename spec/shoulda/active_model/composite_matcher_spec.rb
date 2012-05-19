require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::CompositeMatcher do
  context '#add_matcher' do
    it 'adds a matcher to match against later' do
      sub_matcher = mock('sub matcher', :matches? => true)
      subject = stub('subject')
      composite_matcher = CompositeMatcher.new(:attribute)
      composite_matcher.add_matcher(sub_matcher)
      composite_matcher.matches?(subject)
      sub_matcher.should have_received(:matches?).with(subject)
    end
  end

  context '#description' do
    it 'is a generic description designed to be overridden' do
      CompositeMatcher.new(:attribute).description.should == 'No description'
    end
  end

  context '#matches?' do
    it 'returns true if all sub matchers match' do
      sub_matcher = stub('sub matcher', :matches? => true)
      subject = stub('subject')
      composite_matcher = CompositeMatcher.new(:attribute)
      2.times { composite_matcher.add_matcher(sub_matcher) }
      composite_matcher.matches?(subject).should be_true
    end

    it 'returns false if any sub matcher does not match' do
      matching_sub_matcher = stub('sub matcher', :matches? => true)
      not_matching_sub_matcher = stub('sub matcher', :matches? => false)
      subject = stub('subject')
      composite_matcher = CompositeMatcher.new(:attribute)
      composite_matcher.add_matcher(matching_sub_matcher)
      composite_matcher.add_matcher(not_matching_sub_matcher)
      composite_matcher.matches?(subject).should be_false
    end
  end

  context '#sub_matcher_descriptions' do
    it 'is all of the sub matcher descriptions combined' do
      one = stub('first matcher', :description => 'one')
      two = stub('second matcher', :description => 'two')
      composite_matcher = CompositeMatcher.new(:attribute)
      composite_matcher.add_matcher(one)
      composite_matcher.add_matcher(two)
      composite_matcher.sub_matcher_descriptions.should == 'one, two'
    end
  end
end
