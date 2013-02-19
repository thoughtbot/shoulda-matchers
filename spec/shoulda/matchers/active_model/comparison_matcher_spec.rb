require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ComparisonMatcher do
  context 'validating numericality greater than' do
    subject { validating_numericality(:greater_than => 4) }
    describe "with a value greater than limit" do
      before { subject.attr = 6 }
      it 'should pass' do
        should validate_numericality_of(:attr).is_greater_than(4)
      end
    end
    describe "with a value equal to limit" do
      before { subject.attr = 4 }
      it 'should not pass' do
        should_not validate_numericality_of(:attr).is_greater_than(4)
      end
    end
    describe "with a value less than limit" do
      before { subject.attr = 2 }
      it 'should not pass' do
        should_not validate_numericality_of(:attr).is_greater_than(4)
      end
    end
  end

  context 'validating numericality greater than or equal to ' do
    subject { validating_numericality(:greater_than_equal_to => 4) }
    describe "with a value greater than limit" do
      before { subject.attr = 6 }
      it 'should pass' do
        should validate_numericality_of(:attr).is_greater_than_or_equal_to(4)
      end
    end
    describe "with a value equal to limit" do
      before { subject.attr = 4 }
      it 'should pass' do
        should validate_numericality_of(:attr).is_greater_than_or_equal_to(4)
      end
    end
    describe "with a value less than limit" do
      before { subject.attr = 2 }
      it 'should not pass' do
        should_not validate_numericality_of(:attr).is_greater_than_or_equal_to(4)
      end
    end
  end

  context 'validating numericality equal to ' do
    subject { validating_numericality(:equal_to => 4) }
    describe "with a value greater than limit" do
      before { subject.attr = 6 }
      it 'should not pass' do
        should_not validate_numericality_of(:attr).is_equal_to(4)
      end
    end
    describe "with a value equal to limit" do
      before { subject.attr = 4 }
      it 'should pass' do
        should validate_numericality_of(:attr).is_equal_to(4)
      end
    end
    describe "with a value less than limit" do
      before { subject.attr = 2 }
      it 'should not pass' do
        should_not validate_numericality_of(:attr).is_equal_to(4)
      end
    end
  end

  context 'validating numericality less than ' do
    subject { validating_numericality(:less_than => 4) }
    describe "with a value greater than limit" do
      before { subject.attr = 6 }
      it 'should not pass' do
        should_not validate_numericality_of(:attr).is_less_than(4)
      end
    end
    describe "with a value equal to limit" do
      before { subject.attr = 4 }
      it 'should not pass' do
        should_not validate_numericality_of(:attr).is_less_than(4)
      end
    end
    describe "with a value less than limit" do
      before { subject.attr = 2 }
      it 'should pass' do
        should validate_numericality_of(:attr).is_less_than(4)
      end
    end
  end
  context 'validating numericality less than or equal to  ' do
    subject { validating_numericality(:less_than_or_equal_to => 4) }
    describe "with a value greater than limit" do
      before { subject.attr = 6 }
      it 'should not pass' do
        should_not validate_numericality_of(:attr).is_less_than_or_equal_to(4)
      end
    end
    describe "with a value equal to limit" do
      before { subject.attr = 4 }
      it 'should not pass' do
        should validate_numericality_of(:attr).is_less_than_or_equal_to(4)
      end
    end
    describe "with a value less than limit" do
      before { subject.attr = 2 }
      it 'should pass' do
        should validate_numericality_of(:attr).is_less_than_or_equal_to(4)
      end
    end
  end



  def validating_numericality(options = {})
    define_model(:example, :attr => :integer) do
      validates_numericality_of :attr, options
    end.new
  end
end
