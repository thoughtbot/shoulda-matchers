require 'spec_helper'

describe Shoulda::Matchers::ActionController::SetSessionMatcher do
  context 'a controller that sets a session variable' do
    it 'accepts assigning to that variable' do
      expect(controller_with_session(var: 'hi')).to set_session(:var)
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

    it 'accepts assigning false to that variable' do
      expect(controller_with_session(var: false)).to set_session(:var).to(false)
    end

    it 'accepts assigning to the same value in the test context' do
      expected = 'value'

      expect(controller_with_session(var: expected)).
        to set_session(:var).in_context(self).to { expected }
    end

    it 'rejects assigning to the another value in the test context' do
      expected = 'other'

      expect(controller_with_session(var: 'unexpected')).
        not_to set_session(:var).in_context(self).to { expected }
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
