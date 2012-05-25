require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::FormattedErrorMessageList, '#errors_when' do
  context 'with no errors' do
    it 'returns an empty array' do
      define_model :example, :attr => :string do
        validates_presence_of :attr
      end
      errors = described_class.new(Example.new).errors_when(:attr => 'present')
      errors.should == []
    end
  end

  context 'with one error' do
    it 'has the correct wording' do
      define_model :example, :attr => :string do
        validates_presence_of :attr
      end
      errors = described_class.new(Example.new).errors_when(:attr => nil)
      errors.should == ["attr can't be blank (nil)"]
    end
  end

  context "with multiple attributes" do
    before do
      define_model :example, :attr => :string, :name => :string do
        validates_presence_of :attr
        validates_presence_of :name
      end
    end

    it "has the correct wording" do
      errors = described_class.new(Example.new).errors_when(:attr => nil, :name => "")
      errors.should == ["attr can't be blank (nil)", %{name can't be blank ("")}]
    end
  end
end
