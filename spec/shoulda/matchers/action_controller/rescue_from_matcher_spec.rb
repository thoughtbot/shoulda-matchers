require 'spec_helper'

describe Shoulda::Matchers::ActionController::RescueFromMatcher do
  context 'a controller that rescues from RuntimeError' do
    it 'asserts controller is setup with rescue_from' do
      expect(controller_with_rescue_from).to rescue_from RuntimeError
    end

    context 'with a handler method' do
      it 'asserts rescue_from can find the handler when it is public' do
        controller = controller_with_rescue_from_and_method(:public)
        check_rescue_with_method_for(controller)
      end

      it 'asserts rescue_from can find the handler when it is protected' do
        controller = controller_with_rescue_from_and_method(:protected)
        check_rescue_with_method_for(controller)
      end

      it 'asserts rescue_from can find the handler when it is private' do
        controller = controller_with_rescue_from_and_method(:private)
        check_rescue_with_method_for(controller)
      end

      it 'asserts rescue_from was not set up with incorrect handler method' do
        expect(controller_with_rescue_from_and_method).not_to rescue_from(RuntimeError).with(:other_method)
      end

      it 'asserts the controller responds to the handler method' do
        matcher = rescue_from(RuntimeError).with(:error_method)
        expect(matcher.matches?(controller_with_rescue_from_and_invalid_method)).to eq false
        expect(matcher.failure_message).to match(/does not respond to/)
      end
    end

    context 'without a handler method' do
      it 'the handler method is not included in the description' do
        matcher = rescue_from(RuntimeError)
        expect(matcher.matches?(controller_with_rescue_from)).to eq true
        expect(matcher.description).not_to match(/with #/)
      end
    end
  end

  context 'a controller that does not rescue from RuntimeError' do
    it 'asserts controller is not setup with rescue_from' do
      matcher = rescue_from RuntimeError
      expect(define_controller('RandomController')).not_to matcher
      expect(matcher.failure_message_when_negated).to match(/Did not expect \w+ to rescue from/)
    end
  end

  def check_rescue_with_method_for(controller)
    expect(controller).to rescue_from(RuntimeError).with(:error_method)
  end

  def controller_with_rescue_from
    define_controller 'RescueRuntimeError' do
      rescue_from(RuntimeError) {}
    end
  end

  def controller_with_rescue_from_and_invalid_method
    define_controller 'RescueRuntimeErrorWithMethod' do
      rescue_from RuntimeError, with: :error_method
    end
  end

  def controller_with_rescue_from_and_method(access = :public)
    controller = controller_with_rescue_from_and_invalid_method
    class << controller
      def error_method
        true
      end
    end

    case access
    when :protected
      class << controller
        protected :error_method
      end
    when :private
      class << controller
        private :error_method
      end
    end

    controller
  end
end
