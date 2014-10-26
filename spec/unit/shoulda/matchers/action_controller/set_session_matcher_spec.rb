require 'spec_helper'

describe Shoulda::Matchers::ActionController::SetSessionMatcher do
  context 'a controller that sets a session variable' do
    it 'accepts assigning to that variable' do
      expect(controller_with_session(var: 'hi')).to set_session(:var)
    end

    it 'accepts assigning to that variable with specifying the key by string' do
      expect(controller_with_session(var: 'hi')).to set_session('var')
    end

    it 'accepts assigning the correct value to that variable' do
      expect(controller_with_session(var: 'hi')).to set_session(:var).to('hi')
    end

    it 'rejects assigning another value to that variable' do
      expect(controller_with_session(var: 'hi')).not_to set_session(:var).to('other')
    end

    it 'rejects assigning to another variable' do
      expect(controller_with_session(var: 'hi')).not_to set_session(:other)
    end

    it 'accepts assigning nil to another variable' do
      expect(controller_with_session(var: 'hi')).to set_session(:other).to(nil)
    end

    it 'rejects assigning nil to that variable' do
      expect(controller_with_session(var: 'hi')).not_to set_session(:var).to(nil)
    end

    it 'accepts assigning nil to cleared variable' do
      expect(controller_with_session(var: nil)).to set_session(:var).to(nil)
    end

    it 'accepts assigning false to that variable' do
      expect(controller_with_session(var: false)).to set_session(:var).to(false)
    end

    it 'rejects assigning false to other variable' do
      expect(controller_with_session(var: false)).not_to set_session(:other).to(false)
    end

    it 'rejects assigning false to a variable with value' do
      expect(controller_with_session(var: 'hi')).not_to set_session(:other).to(false)
    end

    it 'accepts assigning to the same value in the test context' do
      context = stub(expected: 'value')

      expect(controller_with_session(var: 'value')).
        to set_session(:var).in_context(context).to { expected }
    end

    it 'rejects assigning to the another value in the test context' do
      context = stub(expected: 'other')

      expect(controller_with_session(var: 'unexpected')).
        not_to set_session(:var).in_context(context).to { expected }
    end

    it 'accepts assigning nil to another variable in the test context' do
      context = stub(expected: nil)

      expect(controller_with_session(var: 'hi')).
        to set_session(:other).in_context(context).to { expected }
    end

    it 'rejects assigning nil to that variable in the test context' do
      context = stub(expected: nil)

      expect(controller_with_session(var: 'hi')).
        not_to set_session(:var).in_context(context).to { expected }
    end

    it 'accepts assigning nil to a cleared variable in the test context' do
      context = stub(expected: nil)

      expect(controller_with_session(var: nil)).
        to set_session(:var).in_context(context).to { expected }
    end

    it 'accepts assigning false to that variable in the test context' do
      context = stub(expected: false)

      expect(controller_with_session(var: false)).
        to set_session(:var).in_context(context).to { expected }
    end

    it 'accepts assigning false to other variable in the test context' do
      context = stub(expected: false)

      expect(controller_with_session(var: false)).
        not_to set_session(:other).in_context(context).to { expected }
    end

    it 'accepts assigning false to other variable in the test context' do
      context = stub(expected: false)

      expect(controller_with_session(var: 'hi')).
        not_to set_session(:var).in_context(context).to { expected }
    end

    def controller_with_session(session_hash)
      build_fake_response do
        session_hash.each do |key, value|
          session[key] = value
        end
      end
    end
  end
end
