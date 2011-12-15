require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateConfirmationOf do

  context "an confirmed attribute with default value" do
    before :each do
      @model = define_model(:example, :attr  => :string,
                                      :other => :integer) do
        validates_confirmation_of :attr
      end.new
    end
    
    it {@model.should validate_confirmation_of :attr}
    it {@model.should_not validate_confirmation_of(:attr).with_message('custom message')}
    it {@model.should validate_confirmation_of(:attr).with_value('new value')}
    it {@model.should validate_confirmation_of(:attr).with_value('new value').with_unconfirmed_value('unconfirmed')}
  end
  
  context "an confirmed attribute with custom message" do
    before :each do
      @model = define_model(:example, :attr  => :string,
                                      :other => :integer) do
        validates_confirmation_of :attr, :message => 'custom message'
      end.new
    end
    it {@model.should_not validate_confirmation_of :attr}
    it {@model.should_not validate_confirmation_of(:attr).with_value('test value')}      
    it {@model.should validate_confirmation_of(:attr).with_message('custom message')}
  end
  
  context "non-confirmed attribute" do
    before :each do
      @model = define_model(:example, :attr  => :string,
                                      :other => :integer) do
        validates_confirmation_of :attr, :message => 'custom message'
      end.new
    end
    it {@model.should_not validate_confirmation_of :attr}
  end
  
end
