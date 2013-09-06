require 'spec_helper'

describe Shoulda::Matchers::ActiveRecord::AcceptNestedAttributesForMatcher do
  it 'accepts an existing declaration' do
    accepting_children.should accept_nested_attributes_for(:children)
  end

  it 'rejects a missing declaration' do
    matcher = children_matcher

    matcher.matches?(rejecting_children).should be_false

    matcher.failure_message_for_should.
      should eq 'Expected Parent to accept nested attributes for children (is not declared)'
  end

  context 'allow_destroy' do
    it 'accepts a valid truthy value' do
      matching = accepting_children(:allow_destroy => true)

      matching.should children_matcher.allow_destroy(true)
    end

    it 'accepts a valid falsey value' do
      matching = accepting_children(:allow_destroy => false)

      matching.should children_matcher.allow_destroy(false)
    end

    it 'rejects an invalid truthy value' do
      matcher = children_matcher
      matching = accepting_children(:allow_destroy => true)

      matcher.allow_destroy(false).matches?(matching).should be_false
      matcher.failure_message_for_should.should =~ /should not allow destroy/
    end

    it 'rejects an invalid falsey value' do
      matcher = children_matcher
      matching = accepting_children(:allow_destroy => false)

      matcher.allow_destroy(true).matches?(matching).should be_false
      matcher.failure_message_for_should.should =~ /should allow destroy/
    end
  end

  context 'limit' do
    it 'accepts a correct value' do
      accepting_children(:limit => 3).should children_matcher.limit(3)
    end

    it 'rejects a false value' do
      matcher = children_matcher
      rejecting = accepting_children(:limit => 3)

      matcher.limit(2).matches?(rejecting).should be_false
      matcher.failure_message_for_should.should =~ /limit should be 2, got 3/
    end
  end

  context 'update_only' do
    it 'accepts a valid truthy value' do
      accepting_children(:update_only => true).
        should children_matcher.update_only(true)
    end

    it 'accepts a valid falsey value' do
      accepting_children(:update_only => false).
        should children_matcher.update_only(false)
    end

    it 'rejects an invalid truthy value' do
      matcher = children_matcher.update_only(false)
      rejecting = accepting_children(:update_only => true)

      matcher.matches?(rejecting).should be_false
      matcher.failure_message_for_should.should =~ /should not be update only/
    end

    it 'rejects an invalid falsey value' do
      matcher = children_matcher.update_only(true)
      rejecting = accepting_children(:update_only => false)

      matcher.matches?(rejecting).should be_false
      matcher.failure_message_for_should.should =~ /should be update only/
    end
  end

  def accepting_children(options = {})
    define_model :child, :parent_id => :integer
    define_model :parent do
      has_many :children
      accepts_nested_attributes_for :children, options
    end.new
  end

  def children_matcher
    accept_nested_attributes_for(:children)
  end

  def rejecting_children
    define_model :child, :parent_id => :integer
    define_model :parent do
      has_many :children
    end.new
  end
end
