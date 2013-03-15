require 'spec_helper'

describe Shoulda::Matchers::ActiveRecord::HaveReadonlyAttributeMatcher do
  context 'a read-only attribute' do
    it 'accepts' do
      with_readonly_attr.should have_readonly_attribute(:attr)
    end
  end

  context 'an attribute that is not part of the read-only set' do
    it 'rejects being read-only' do
      model = define_model :example, :attr => :string, :other => :string do
        attr_readonly :attr
      end.new

      model.should_not have_readonly_attribute(:other)
    end
  end

  context 'an attribute on a class with no readonly attributes' do
    it 'rejects being read-only' do
      define_model(:example, :attr => :string).new.
        should_not have_readonly_attribute(:attr)
    end

    it 'assigns a failure message' do
      model = define_model(:example, :attr => :string).new
      matcher = have_readonly_attribute(:attr)

      matcher.matches?(model)

      matcher.failure_message_for_should.should_not be_nil
    end
  end

  def with_readonly_attr
    define_model :example, :attr => :string do
      attr_readonly :attr
    end.new
  end
end
