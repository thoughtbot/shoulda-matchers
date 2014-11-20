require 'unit_spec_helper'

describe Shoulda::Matchers::ActionController, '#set_session' do
  context 'a controller that sets a session variable' do
    context 'with #[]' do
      context 'when the given key is present in session' do
        it 'accepts' do
          expect(controller_with_session(var: 'hi')).to set_session[:var]
        end

        it 'accepts when expected key is a string' do
          expect(controller_with_session(var: 'hi')).to set_session['var']
        end
      end

      context 'when the given key is not present in session' do
        it 'rejects' do
          expect(controller_with_session(var: 'hi')).not_to set_session[:other]
        end
      end
    end

    context 'with #[] + #to' do
      context 'given a static value' do
        context 'when the given key and value are present in session' do
          it 'accepts' do
            expect(controller_with_session(var: 'hi')).to set_session[:var].to('hi')
          end

          it 'accepts given nil' do
            expect(controller_with_session(var: nil)).to set_session[:var].to(nil)
          end

          it 'accepts given false' do
            expect(controller_with_session(var: false)).to set_session[:var].to(false)
          end
        end

        context 'when the given key is present in session but not the given value' do
          it 'rejects' do
            expect(controller_with_session(var: 'hi')).not_to set_session[:var].to('other')
          end

          it 'rejects given nil' do
            expect(controller_with_session(var: 'hi')).not_to set_session[:var].to(nil)
          end
        end

        context 'when the given key is not present in session' do
          it 'accepts given nil' do
            expect(controller_with_session(var: 'hi')).to set_session[:other].to(nil)
          end

          it 'rejects given false' do
            expect(controller_with_session(var: false)).not_to set_session[:other].to(false)
          end
        end
      end

      context 'given a dynamic value' do
        context 'when the given key and value are present in session' do
          it 'accepts' do
            context = double(expected: 'value')

            expect(controller_with_session(var: 'value')).
              to set_session[:var].in_context(context).to { expected }
          end

          it 'accepts given nil' do
            context = double(expected: nil)

            expect(controller_with_session(var: nil)).
              to set_session[:var].in_context(context).to { expected }
          end

          it 'accepts given false' do
            context = double(expected: false)

            expect(controller_with_session(var: false)).
              to set_session[:var].in_context(context).to { expected }
          end
        end

        context 'when the given key is present in session but not the given value' do
          it 'rejects given nil' do
            context = double(expected: nil)

            expect(controller_with_session(var: 'hi')).
              not_to set_session[:var].in_context(context).to { expected }
          end

          it 'rejects given false' do
            context = double(expected: false)

            expect(controller_with_session(var: 'hi')).
              not_to set_session[:var].in_context(context).to { expected }
          end
        end

        context 'when the given key is not present in session' do
          it 'rejects' do
            context = double(expected: 'other')

            expect(controller_with_session(var: 'unexpected')).
              not_to set_session[:var].in_context(context).to { expected }
          end

          it 'accepts given nil' do
            context = double(expected: nil)

            expect(controller_with_session(var: 'hi')).
              to set_session[:other].in_context(context).to { expected }
          end

          it 'rejects given false' do
            context = double(expected: false)

            expect(controller_with_session(var: false)).
              not_to set_session[:other].in_context(context).to { expected }
          end
        end
      end
    end
  end

  def controller_with_session(session_hash)
    build_fake_response do
      session_hash.each do |key, value|
        session[key] = value
      end
    end
  end
end
