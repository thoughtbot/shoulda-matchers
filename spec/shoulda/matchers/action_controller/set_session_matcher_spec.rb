require 'spec_helper'

describe Shoulda::Matchers::ActionController::SetSessionMatcher do
  context 'a controller that sets a session variable' do
    it 'accepts assigning to that variable' do
      controller_with_session(:var => 'hi').should set_session(:var)
    end

    it 'accepts assigning the correct value to that variable' do
      controller_with_session(:var => 'hi').should set_session(:var).to('hi')
    end

    it 'rejects assigning another value to that variable' do
      controller_with_session(:var => 'hi').should_not set_session(:var).to('other')
    end

    it 'rejects assigning to another variable' do
      controller_with_session(:var => 'hi').should_not set_session(:other)
    end

    it 'accepts assigning nil to another variable' do
      controller_with_session(:var => 'hi').should set_session(:other).to(nil)
    end

    it 'accepts assigning false to that variable' do
      controller_with_session(:var => false).should set_session(:var).to(false)
    end

    it 'accepts assigning to the same value in the test context' do
      expected = 'value'

      controller_with_session(:var => expected).
        should set_session(:var).in_context(self).to { expected }
    end

    it 'rejects assigning to the another value in the test context' do
      expected = 'other'

      controller_with_session(:var => 'unexpected').
        should_not set_session(:var).in_context(self).to { expected }
    end

    def controller_with_session(session_hash)
      build_response do
        session_hash.each do |key, value|
          session[key] = value
        end
      end
    end
  end
end
