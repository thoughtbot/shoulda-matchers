require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::FormattedErrorMessage, '#message' do
  it 'has the correct wording' do
    define_model :example, :attr => :string do
      attr_accessible :attr
      validates_presence_of :attr
    end
    instance = Example.new(:attr => nil)
    error_message = first_error_message_for(instance)

    message = described_class.new(instance, :attr).message(error_message)
    message.should == "attr can't be blank (nil)"
  end

  it 'does not display attribute value when error is on :base' do
    define_model :example, :attr => :string do
      attr_accessible :attr
      validates :attr, :with => :my_custom_validation

      private

      def my_custom_validation
        errors.add(:base, "is silly")
      end
    end

    instance = Example.new(:attr => nil)
    error_message = first_error_message_for(instance)

    message = described_class.new(instance, :base).message(error_message)
    message.should == "base is silly"
  end

  def first_error_message_for(instance)
    instance.valid?
    instance.errors.first[1]
  end
end
