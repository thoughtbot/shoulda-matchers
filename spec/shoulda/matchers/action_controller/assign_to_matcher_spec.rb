require 'spec_helper'

describe Shoulda::Matchers::ActionController::AssignToMatcher do
  it 'includes the actual class in the failure message' do
    define_class(:WrongClass) do
      def to_s
        'wrong class'
      end
    end

    controller = build_response { @var = WrongClass.new }
    matcher = assign_to(:var).with_kind_of(Fixnum)
    matcher.matches?(controller)

    matcher.failure_message_for_should.should =~ /but got wrong class \(WrongClass\)$/
  end

  context 'a controller that assigns to an instance variable' do
    it 'accepts assigning to that variable' do
      controller.should assign_to(:var)
    end

    it 'accepts assigning to that variable with the correct class' do
      controller.should assign_to(:var).with_kind_of(String)
    end

    it 'rejects assigning to that variable with another class' do
      controller.should_not assign_to(:var).with_kind_of(Fixnum)
    end

    it 'accepts assigning the correct value to that variable' do
      controller.should assign_to(:var).with('value')
    end

    it 'rejects assigning another value to that variable' do
      controller.should_not assign_to(:var).with('other')
    end

    it 'rejects assigning to another variable' do
      controller.should_not assign_to(:other)
    end

    it 'accepts assigning to the same value in the test context' do
      expected = 'value'
      controller.should assign_to(:var).in_context(self).with { expected }
    end

    it 'rejects assigning to the another value in the test context' do
      expected = 'other'
      controller.should_not assign_to(:var).in_context(self).with { expected }
    end

    def controller
      build_response { @var = 'value' }
    end
  end

  context 'a controller that assigns a nil value to an instance variable' do
    it 'accepts assigning to that variable' do
      controller = build_response do
        @var = nil
      end
      controller.should assign_to(:var)
    end
  end
end
