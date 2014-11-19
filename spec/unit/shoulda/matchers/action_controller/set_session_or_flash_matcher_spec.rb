require 'unit_spec_helper'

describe Shoulda::Matchers::ActionController::SetSessionOrFlashMatcher do
  context 'without any qualifiers' do
    it 'produces the right description' do
      store = build_store(name: 'flash')
      matcher = described_class.new(store)
      expected_description = 'should set any key in flash'

      expect(matcher.description).to eq expected_description
    end

    context 'in the positive' do
      context 'if the store is not empty' do
        it 'accepts' do
          controller = define_class('MyController').new
          store = build_store(empty?: false)
          matcher = described_class.new(store)

          expect(controller).to matcher
        end
      end

      context 'if the store is empty' do
        it 'rejects' do
          controller = define_class('MyController').new
          store = build_store(empty?: true)
          matcher = described_class.new(store)

          expect(controller).not_to matcher
        end

        it 'produces the correct failure message' do
          controller = define_class('MyController').new
          store = build_store(name: 'flash', empty?: true)
          matcher = described_class.new(store)
          expected_message = 'Expected MyController to set any key in flash, but it did not'

          expect { expect(controller).to matcher }.
            to fail_with_message(expected_message)
        end
      end
    end

    context 'in the negative' do
      context 'if the given key is present in the store' do
        it 'produces the correct failure message' do
          controller = define_class('MyController').new
          store = build_store(name: 'flash', empty?: false)
          matcher = described_class.new(store)
          expected_message = 'Expected MyController not to set any key in flash, but it did'

          expect { expect(controller).not_to matcher }.
            to fail_with_message(expected_message)
        end
      end
    end
  end

  context 'with #[]' do
    it 'produces the right description' do
      store = build_store(name: 'flash')
      matcher = described_class.new(store)['the key']
      expected_description = 'should set flash["the key"]'

      expect(matcher.description).to eq expected_description
    end

    context 'in the positive' do
      context 'if the given key is present in the store' do
        it 'accepts' do
          controller = define_class('MyController').new
          store = build_store
          allow(store).to receive(:has_key?).
            with('the key').
            and_return(true)
          matcher = described_class.new(store)['the key']

          expect(controller).to matcher
        end
      end

      context 'if the given key is not present in the store' do
        it 'rejects' do
          controller = define_class('MyController').new
          store = build_store
          allow(store).to receive(:has_key?).
            with('the key').
            and_return(false)
          matcher = described_class.new(store)['the key']

          expect(controller).not_to matcher
        end

        it 'produces the correct failure message' do
          controller = define_class('MyController').new
          store = build_store(name: 'flash')
          allow(store).to receive(:has_key?).
            with('the key').
            and_return(false)
          matcher = described_class.new(store)['the key']
          expected_message = 'Expected MyController to set flash["the key"], but it did not'

          expect { expect(controller).to matcher }.
            to fail_with_message(expected_message)
        end
      end
    end

    context 'in the negative' do
      context 'if the given key is present in the store' do
        it 'produces the correct failure message' do
          controller = define_class('MyController').new
          store = build_store(name: 'flash')
          allow(store).to receive(:has_key?).
            with('the key').
            and_return(true)
          matcher = described_class.new(store)['the key']
          expected_message = 'Expected MyController not to set flash["the key"], but it did'

          expect { expect(controller).not_to matcher }.
            to fail_with_message(expected_message)
        end
      end
    end
  end

  context 'with #to' do
    context 'given a static value' do
      it 'produces the right description' do
        store = build_store(name: 'flash')
        matcher = described_class.new(store).to('the value')
        expected_description = 'should set any key in flash to "the value"'

        expect(matcher.description).to eq expected_description
      end

      context 'in the positive' do
        context 'if the given value is present in the store' do
          it 'accepts' do
            controller = define_class('MyController').new
            store = build_store
            allow(store).to receive(:has_value?).
              with('the value').
              and_return(true)
            matcher = described_class.new(store).to('the value')

            expect(controller).to matcher
          end

          it 'accepts given a value of nil' do
            controller = define_class('MyController').new
            store = build_store
            allow(store).to receive(:has_value?).
              with(nil).
              and_return(true)
            matcher = described_class.new(store).to(nil)

            expect(controller).to matcher
          end

          it 'accepts given a value of false' do
            controller = define_class('MyController').new
            store = build_store
            allow(store).to receive(:has_value?).
              with(false).
              and_return(true)
            matcher = described_class.new(store).to(false)

            expect(controller).to matcher
          end
        end

        context 'if the given value is not present in the store' do
          it 'rejects' do
            controller = define_class('MyController').new
            store = build_store
            allow(store).to receive(:has_value?).
              with('the value').
              and_return(false)
            matcher = described_class.new(store).to('the value')

            expect(controller).not_to matcher
          end

          it 'produces the correct failure message' do
            controller = define_class('MyController').new
            store = build_store(name: 'flash')
            allow(store).to receive(:has_value?).
              with('the value').
              and_return(false)
            matcher = described_class.new(store).to('the value')
            expected_message = 'Expected MyController to set any key in flash to "the value", but it did not'

            expect { expect(controller).to matcher }.
              to fail_with_message(expected_message)
          end
        end
      end

      context 'in the negative' do
        context 'if the given value is present in the store' do
          it 'produces the correct failure message' do
            controller = define_class('MyController').new
            store = build_store(name: 'flash')
            allow(store).to receive(:has_value?).
              with('the value').
              and_return(true)
            matcher = described_class.new(store).to('the value')
            expected_message = 'Expected MyController not to set any key in flash to "the value", but it did'

            expect { expect(controller).not_to matcher }.
              to fail_with_message(expected_message)
          end
        end
      end
    end

    context 'given a regexp' do
      it 'produces the right description' do
        store = build_store(name: 'flash')
        matcher = described_class.new(store).to(/the value/)
        expected_description = 'should set any key in flash to a value matching /the value/'

        expect(matcher.description).to eq expected_description
      end

      context 'in the positive' do
        context 'if the given value is present in the store' do
          it 'accepts' do
            controller = define_class('MyController').new
            store = build_store
            allow(store).to receive(:has_value?).
              with(/the value/).
              and_return(true)
            matcher = described_class.new(store).to(/the value/)

            expect(controller).to matcher
          end
        end

        context 'if the given value is not present in the store' do
          it 'rejects' do
            controller = define_class('MyController').new
            store = build_store
            allow(store).to receive(:has_value?).
              with(/the value/).
              and_return(false)
            matcher = described_class.new(store).to(/the value/)

            expect(controller).not_to matcher
          end

          it 'produces the correct failure message' do
            controller = define_class('MyController').new
            store = build_store(name: 'flash')
            allow(store).to receive(:has_value?).
              with(/the value/).
              and_return(false)
            matcher = described_class.new(store).to(/the value/)
            expected_message = 'Expected MyController to set any key in flash to a value matching /the value/, but it did not'

            expect { expect(controller).to matcher }.
              to fail_with_message(expected_message)
          end
        end
      end

      context 'in the negative' do
        context 'if the given value is present in the store' do
          it 'produces the correct failure message' do
            controller = define_class('MyController').new
            store = build_store(name: 'flash')
            allow(store).to receive(:has_value?).
              with(/the value/).
              and_return(true)
            matcher = described_class.new(store).to(/the value/)
            expected_message = 'Expected MyController not to set any key in flash to a value matching /the value/, but it did'

            expect { expect(controller).not_to matcher }.
              to fail_with_message(expected_message)
          end
        end
      end
    end

    context 'given a dynamic value' do
      it 'produces the right description' do
        store = build_store(name: 'flash')
        context = double('context', method_in_context: 'the value')
        matcher = described_class.new(store).
          in_context(context).
          to { method_in_context }
        expected_description = 'should set any key in flash to "the value"'

        expect(matcher.description).to eq expected_description
      end

      it 'requires in_context to be specified beforehand' do
        store = build_store(name: 'flash')
        matcher = described_class.new(store)
        expected_message = 'When specifying a value as a block, a context must be specified beforehand, e.g., flash.in_context(context).to { ... }'

        expect { matcher.to { whatever } }.
          to raise_error(ArgumentError, expected_message)
      end

      context 'in the positive' do
        context 'if the value evaluated in the context is present in the store' do
          it 'accepts' do
            controller = define_class('MyController').new
            store = build_store
            allow(store).to receive(:has_value?).
              with('the value').
              and_return(true)
            context = double('context', method_in_context: 'the value')
            matcher = described_class.new(store).
              in_context(context).
              to { method_in_context }

            expect(controller).to matcher
          end
        end

        context 'if the value evaluated in the context is not present in the store' do
          it 'rejects' do
            controller = define_class('MyController').new
            store = build_store
            allow(store).to receive(:has_value?).
              with('the value').
              and_return(false)
            context = double('context', method_in_context: 'the value')
            matcher = described_class.new(store).
              in_context(context).
              to { method_in_context }

            expect(controller).not_to matcher
          end

          it 'produces the correct failure message' do
            controller = define_class('MyController').new
            store = build_store(name: 'flash')
            allow(store).to receive(:has_value?).
              with('the value').
              and_return(false)
            context = double('context', method_in_context: 'the value')
            matcher = described_class.new(store).
              in_context(context).
              to { method_in_context }
            expected_message = 'Expected MyController to set any key in flash to "the value", but it did not'

            expect { expect(controller).to matcher }.
              to fail_with_message(expected_message)
          end
        end
      end

      context 'in the negative' do
        context 'if the value evaluated in the context is present in the store' do
          it 'produces the correct failure message' do
            controller = define_class('MyController').new
            store = build_store(name: 'flash')
            allow(store).to receive(:has_value?).
              with('the value').
              and_return(true)
            context = double('context', method_in_context: 'the value')
            matcher = described_class.new(store).
              in_context(context).
              to { method_in_context }
            expected_message = 'Expected MyController not to set any key in flash to "the value", but it did'

            expect { expect(controller).not_to matcher }.
              to fail_with_message(expected_message)
          end
        end
      end
    end
  end

  context 'with #[] + #to' do
    context 'given a static value' do
      it 'produces the right description' do
        store = build_store(name: 'flash')
        matcher = described_class.new(store)['the key'].to('the value')
        expected_description = 'should set flash["the key"] to "the value"'

        expect(matcher.description).to eq expected_description
      end

      context 'in the positive' do
        context 'if the given value is present in the store' do
          it 'accepts' do
            controller = define_class('MyController').new
            store = build_store
            allow(store).to receive(:has_key?).
              with('the key').
              and_return(true)
            allow(store).to receive(:has_value?).
              with('the value').
              and_return(true)
            matcher = described_class.new(store)['the key'].to('the value')

            expect(controller).to matcher
          end
        end

        context 'if the given value is not present in the store' do
          it 'rejects' do
            controller = define_class('MyController').new
            store = build_store
            allow(store).to receive(:has_key?).
              with('the key').
              and_return(true)
            allow(store).to receive(:has_value?).
              with('the value').
              and_return(false)
            matcher = described_class.new(store)['the key'].to('the value')

            expect(controller).not_to matcher
          end

          it 'produces the correct failure message' do
            controller = define_class('MyController').new
            store = build_store(name: 'flash')
            allow(store).to receive(:has_key?).
              with('the key').
              and_return(true)
            allow(store).to receive(:has_value?).
              with('the value').
              and_return(false)
            matcher = described_class.new(store)['the key'].to('the value')
            expected_message = 'Expected MyController to set flash["the key"] to "the value", but it did not'

            expect { expect(controller).to matcher }.
              to fail_with_message(expected_message)
          end
        end
      end

      context 'in the negative' do
        context 'if the given value is present in the store' do
          it 'produces the correct failure message' do
            controller = define_class('MyController').new
            store = build_store(name: 'flash')
            allow(store).to receive(:has_key?).
              with('the key').
              and_return(true)
            allow(store).to receive(:has_value?).
              with('the value').
              and_return(true)
            matcher = described_class.new(store)['the key'].to('the value')
            expected_message = 'Expected MyController not to set flash["the key"] to "the value", but it did'

            expect { expect(controller).not_to matcher }.
              to fail_with_message(expected_message)
          end
        end
      end
    end

    context 'given a dynamic value' do
      it 'produces the right description' do
        store = build_store(name: 'flash')
        context = double('context', method_in_context: 'the value')
        matcher = described_class.new(store)['the key'].
          in_context(context).
          to { method_in_context }
        expected_description = 'should set flash["the key"] to "the value"'

        expect(matcher.description).to eq expected_description
      end

      context 'in the positive' do
        context 'if the value evaluated in the context is present in the store' do
          it 'accepts' do
            controller = define_class('MyController').new
            store = build_store
            allow(store).to receive(:has_key?).
              with('the key').
              and_return(true)
            allow(store).to receive(:has_value?).
              with('the value').
              and_return(true)
            context = double('context', method_in_context: 'the value')
            matcher = described_class.new(store)['the key'].
              in_context(context).
              to { method_in_context }

            expect(controller).to matcher
          end
        end

        context 'if the value evaluated in the context is not present in the store' do
          it 'rejects' do
            controller = define_class('MyController').new
            store = build_store
            allow(store).to receive(:has_key?).
              with('the key').
              and_return(false)
            context = double('context', method_in_context: 'the value')
            matcher = described_class.new(store)['the key'].
              in_context(context).
              to { method_in_context }

            expect(controller).not_to matcher
          end

          it 'produces the correct failure message' do
            controller = define_class('MyController').new
            store = build_store(name: 'flash')
            allow(store).to receive(:has_key?).
              with('the key').
              and_return(false)
            context = double('context', method_in_context: 'the value')
            matcher = described_class.new(store)['the key'].
              in_context(context).
              to { method_in_context }
            expected_message = 'Expected MyController to set flash["the key"] to "the value", but it did not'

            expect { expect(controller).to matcher }.
              to fail_with_message(expected_message)
          end
        end
      end

      context 'in the negative' do
        context 'if the value evaluated in the context is present in the store' do
          it 'produces the correct failure message' do
            controller = define_class('MyController').new
            store = build_store(name: 'flash')
            allow(store).to receive(:has_key?).
              with('the key').
              and_return(true)
            allow(store).to receive(:has_value?).
              with('the value').
              and_return(true)
            context = double('context', method_in_context: 'the value')
            matcher = described_class.new(store)['the key'].
              in_context(context).
              to { method_in_context }
            expected_message = 'Expected MyController not to set flash["the key"] to "the value", but it did'

            expect { expect(controller).not_to matcher }.
              to fail_with_message(expected_message)
          end
        end
      end
    end
  end

  def build_store(overrides = {})
    defaults = {
      :name => 'store',
      :controller= => nil,
      :has_key? => nil,
      :has_value? => nil,
      :empty? => nil,
    }
    methods = defaults.merge(overrides)
    double('store', methods)
  end
end
