require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveRecord::HaveReadonlyAttributeMatcher, type: :model do
  context 'a read-only attribute' do
    it 'accepts' do
      expect(with_readonly_attr).to have_readonly_attribute(:attr)
    end
  end

  context 'an attribute that is not part of the read-only set' do
    it 'rejects being read-only' do
      model = define_model :example, attr: :string, other: :string do
        attr_readonly :attr
      end.new

      expect(model).not_to have_readonly_attribute(:other)
    end
  end

  context 'an attribute on a class with no readonly attributes' do
    it 'rejects being read-only' do
      expect(define_model(:example, attr: :string).new).
        not_to have_readonly_attribute(:attr)
    end

    it 'assigns a failure message' do
      model = define_model(:example, attr: :string).new
      matcher = have_readonly_attribute(:attr)

      matcher.matches?(model)

      expect(matcher.failure_message).not_to be_nil
    end
  end

  def with_readonly_attr
    define_model :example, attr: :string do
      attr_readonly :attr
    end.new
  end
end
