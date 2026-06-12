require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveRecord::HaveReadonlyAttributeMatcher, type: :model do
  context 'passing multiple attributes' do
    it 'accepts when every attribute is read-only' do
      record = define_model(:example, attr1: :string, attr2: :string) do
        attr_readonly :attr1, :attr2
      end.new

      expect(record).to have_readonly_attribute(:attr1, :attr2)
    end

    it 'rejects when one attribute is read-only and one is not' do
      record = define_model(:example, attr1: :string, attr2: :string) do
        attr_readonly :attr1
      end.new

      assertion = lambda do
        expect(record).to have_readonly_attribute(:attr1, :attr2)
      end

      message = <<-MESSAGE
Expected Example to make attr2 read-only, but this could not be proved.
  Example is making attr1 read-only, but not attr2.
      MESSAGE

      expect(&assertion).to fail_with_message(message)
    end

    it 'rejects when no attribute is read-only' do
      record = define_model(:example, attr1: :string, attr2: :string).new

      assertion = lambda do
        expect(record).to have_readonly_attribute(:attr1, :attr2)
      end

      message = <<-MESSAGE
Expected Example to make attr1 read-only and make attr2 read-only, but
this could not be proved.
  Example attribute attr1 is not read-only
  Example attribute attr2 is not read-only
      MESSAGE

      expect(&assertion).to fail_with_message(message)
    end
  end

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
