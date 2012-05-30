require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::PositiveErrorDescription, '#matched_error' do
  context 'with no errors' do
    it 'returns an empty string' do
      define_model(:Example, :attr => :string)
      described_class.new(Example.new, :attr, 'whatever', 'message').matched_error.should == ''
    end
  end

  context 'with an error that matches the expected message string' do
    it 'returns the matched error' do
      define_model(:Example, :attr => :string) do
        validates :attr, :presence => true
      end
      positive_error_description = described_class.new(Example.new, :attr, '', "can't be blank")
      positive_error_description.matched_error.should == "can't be blank"
    end
  end

  context 'with an error that matches the expected message regexp' do
    it 'returns the matched error' do
      define_model(:Example, :attr => :string) do
      define_model(:Example, :attr => :string) do
        validates :attr, :presence => true
      end
      positive_error_description = described_class.new(Example.new, :attr, '', "can't be blank")
      positive_error_description.matched_error.should == "can't be blank"
    end
  end

  context 'with an error that matches the expected message regexp' do
    it 'returns the matched error' do
        validates :attr, :presence => true
      end
      positive_error_description = described_class.new(Example.new, :attr, '', /blank/)
      positive_error_description.matched_error.should == "can't be blank"
    end
  end

  context 'when there is an error but it does not match the expected message' do
    it 'returns an empty string' do
      define_model(:Example, :attr => :string) do
        validates :attr, :presence => true
      end
      positive_error_description = described_class.new(Example.new, :attr, '', /no-match/)
      positive_error_description.matched_error.should == ''
    end
  end

  context 'when the expected message is nil' do
    it 'returns the first matching error when there are errors' do
      define_model(:Example, :attr => :string) do
        validates :attr, :presence => true,
          :format => { :with => 'abc' }
      end
      positive_error_description = described_class.new(Example.new, :attr, '', nil)
      positive_error_description.matched_error.should == "can't be blank"
    end

    it 'returns a blank string when there are no errors' do
      define_model(:Example, :attr => :string) do
        validates :attr, :presence => true
      end
      positive_error_description = described_class.new(Example.new, :attr, 'present', nil)
      positive_error_description.matched_error.should == ""
    end
  end
end

describe Shoulda::Matchers::ActiveModel::PositiveErrorDescription, '#matches?' do
  it 'returns true when there is a matched error' do
    define_model(:Example, :attr => :string) do
      validates :attr, :presence => true
    end
    positive_error_description = described_class.new(Example.new, :attr, '', nil)
    positive_error_description.matches?.should be_false
  end

  it 'returns false when there is no matched error' do
    define_model(:Example, :attr => :string) do
      validates :attr, :presence => true
    end
    positive_error_description = described_class.new(Example.new, :attr, 'present', nil)
    positive_error_description.matches?.should be_false
  end
end
