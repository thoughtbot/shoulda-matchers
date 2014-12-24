require 'unit_spec_helper'

describe Shoulda::Matchers::ActionController, '#set_session', type: :controller do
  context 'passing an argument to the initializer' do
    it 'is deprecated in favor of using #[]' do
      expectation = proc { set_session(:foo) }

      expect(&expectation).to print_warning_including(
        'Passing a key to set_session is deprecated'
      )
    end

    it 'still works regardless' do
      silence_warnings do
        expect(controller_with_session(var: 'hi')).to set_session(:var)
      end
    end
  end

  context 'a controller that sets a session variable' do
    context 'without any qualifiers' do
      it 'accepts' do
        expect(controller_with_session(var: 'hi')).to set_session
      end
    end

    context 'with #to' do
      context 'given a static value' do
        context 'when any key in session has the given value' do
          it 'accepts' do
            expect(controller_with_session(var: 'hi')).
              to set_session.to('hi')
          end

          it 'accepts given nil' do
            silence_warnings do
              expect(controller_with_session(var: nil)).
                to set_session.to(nil)
            end
          end

          it 'accepts given false' do
            expect(controller_with_session(var: false)).
              to set_session.to(false)
          end
        end

        context 'when no key in session has the given value' do
          it 'rejects' do
            expect(controller_with_session(var: 'hi')).
              not_to set_session.to('different')
          end
        end
      end

      context 'given a dynamic value' do
        context 'when any key in session has the given value' do
          it 'accepts' do
            context = double(expected: 'hi')
            expect(controller_with_session(var: 'hi')).
              to set_session.in_context(context).to { expected }
          end

          it 'accepts given nil' do
            silence_warnings do
              context = double(expected: nil)
              expect(controller_with_session(var: nil)).
                to set_session.in_context(context).to { expected }
            end
          end

          it 'accepts given false' do
            context = double(expected: false)
            expect(controller_with_session(var: false)).
              to set_session.in_context(context).to { expected }
          end
        end

        context 'when no key in session has the given value' do
          it 'rejects' do
            context = double(expected: 'different')
            expect(controller_with_session(var: 'hi')).
              not_to set_session.in_context(context).to { expected }
          end
        end
      end

      context 'given a regexp' do
        context 'when any value in session matches the regexp' do
          it 'accepts' do
            expect(controller_with_session(var: 'hello')).
              to set_session.to(/ello/)
          end
        end

        context 'when no value in session matches the regexp' do
          it 'rejects' do
            expect(controller_with_session(var: 'hello')).
              not_to set_session.to(/different/)
          end
        end
      end
    end

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
            expect(controller_with_session(var: 'hi')).
              to set_session[:var].to('hi')
          end

          it 'accepts given nil' do
            silence_warnings do
              expect(controller_with_session(var: nil)).
                to set_session[:var].to(nil)
            end
          end

          it 'accepts given false' do
            expect(controller_with_session(var: false)).
              to set_session[:var].to(false)
          end
        end

        context 'when the given key is present in session but not the given value' do
          it 'rejects' do
            expect(controller_with_session(var: 'hi')).
              not_to set_session[:var].to('other')
          end

          it 'rejects given nil' do
            expect(controller_with_session(var: 'hi')).
              not_to set_session[:var].to(nil)
          end
        end

        context 'when the given key is not present in session' do
          it 'accepts given nil' do
            silence_warnings do
              expect(controller_with_session(var: 'hi')).
                to set_session[:other].to(nil)
            end
          end

          it 'rejects given false' do
            expect(controller_with_session(var: false)).
              not_to set_session[:other].to(false)
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
            silence_warnings do
              context = double(expected: nil)

              expect(controller_with_session(var: nil)).
                to set_session[:var].in_context(context).to { expected }
            end
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
            silence_warnings do
              context = double(expected: nil)

              expect(controller_with_session(var: 'hi')).
                to set_session[:other].in_context(context).to { expected }
            end
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

  context 'a controller that does not set any session variables' do
    context 'without any qualifiers' do
      it 'rejects' do
        expect(controller_without_session).not_to set_session
      end
    end

    context 'with #[]' do
      it 'rejects' do
        expect(controller_without_session).
          not_to set_session['any key']
      end
    end

    context 'with #to' do
      it 'rejects' do
        expect(controller_without_session).
          not_to set_session.to('any value')
      end
    end

    context 'with #[] + #to' do
      it 'rejects' do
        expect(controller_without_session).
          not_to set_session['any key'].to('any value')
      end

      it 'prints a warning when using .to(nil) to assert that a variable is unset' do
        expectation = proc do
          expect(controller_without_session).to set_session['any key'].to(nil)
        end

        expected_warning = <<EOT
  Using `should set_session[...].to(nil)` to assert that a variable is unset is deprecated.
  Please use `should_not set_session[...]` instead.
EOT

        expect(&expectation).to print_warning_including(expected_warning)
      end
    end
  end

  def controller_without_session
    build_fake_response
  end

  def controller_with_session(session_hash)
    build_fake_response do
      session_hash.each do |key, value|
        session[key] = value
      end
    end
  end
end
