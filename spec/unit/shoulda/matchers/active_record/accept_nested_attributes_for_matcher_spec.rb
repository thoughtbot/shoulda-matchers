require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveRecord::AcceptNestedAttributesForMatcher, type: :model do
  it 'accepts an existing declaration' do
    expect(accepting_children).to accept_nested_attributes_for(:children)
  end

  it 'rejects a missing declaration' do
    matcher = children_matcher

    expect(matcher.matches?(rejecting_children)).to eq false

    expect(matcher.failure_message).
      to eq 'Expected Parent to accept nested attributes for children (is not declared)'
  end

  context 'allow_destroy' do
    it 'accepts a valid truthy value' do
      matching = accepting_children(allow_destroy: true)

      expect(matching).to children_matcher.allow_destroy(true)
    end

    it 'accepts a valid falsey value' do
      matching = accepting_children(allow_destroy: false)

      expect(matching).to children_matcher.allow_destroy(false)
    end

    it 'rejects an invalid truthy value' do
      matcher = children_matcher
      matching = accepting_children(allow_destroy: true)

      expect(matcher.allow_destroy(false).matches?(matching)).to eq false
      expect(matcher.failure_message).to match(/should not allow destroy/)
    end

    it 'rejects an invalid falsey value' do
      matcher = children_matcher
      matching = accepting_children(allow_destroy: false)

      expect(matcher.allow_destroy(true).matches?(matching)).to eq false
      expect(matcher.failure_message).to match(/should allow destroy/)
    end
  end

  context 'limit' do
    it 'accepts a correct value' do
      expect(accepting_children(limit: 3)).to children_matcher.limit(3)
    end

    it 'rejects a false value' do
      matcher = children_matcher
      rejecting = accepting_children(limit: 3)

      expect(matcher.limit(2).matches?(rejecting)).to eq false
      expect(matcher.failure_message).to match(/limit should be 2, got 3/)
    end
  end

  context 'update_only' do
    it 'accepts a valid truthy value' do
      expect(accepting_children(update_only: true)).
        to children_matcher.update_only(true)
    end

    it 'accepts a valid falsey value' do
      expect(accepting_children(update_only: false)).
        to children_matcher.update_only(false)
    end

    it 'rejects an invalid truthy value' do
      matcher = children_matcher.update_only(false)
      rejecting = accepting_children(update_only: true)

      expect(matcher.matches?(rejecting)).to eq false
      expect(matcher.failure_message).to match(/should not be update only/)
    end

    it 'rejects an invalid falsey value' do
      matcher = children_matcher.update_only(true)
      rejecting = accepting_children(update_only: false)

      expect(matcher.matches?(rejecting)).to eq false
      expect(matcher.failure_message).to match(/should be update only/)
    end
  end

  def accepting_children(options = {})
    define_model :child, parent_id: :integer
    define_model :parent do
      has_many :children
      accepts_nested_attributes_for :children, options
    end.new
  end

  def children_matcher
    accept_nested_attributes_for(:children)
  end

  def rejecting_children
    define_model :child, parent_id: :integer
    define_model :parent do
      has_many :children
    end.new
  end
end
