shared_examples_for 'set session or flash matcher' do
  context 'without any qualifiers' do
    it 'produces the right description' do
      expected_description = "should set any key in #{store_name}"
      matcher = set_store

      expect(matcher.description).to eq expected_description
    end

    context 'in the positive' do
      context 'if the store is not empty' do
        it 'accepts' do
          controller = controller_with_store('any key' => 'any value')
          expect(controller).to set_store
        end
      end

      context 'if the store is empty' do
        it 'rejects' do
          controller = controller_with_empty_store
          expect(controller).not_to set_store
        end

        it 'produces the correct failure message' do
          controller = controller_with_empty_store
          expected_message = %<Expected #{controller.class} to set any key in #{store_name}, but it did not>

          expect { expect(controller).to set_store }.
            to fail_with_message(expected_message)
        end
      end
    end

    context 'in the negative' do
      context 'if the given key is present in the store' do
        it 'produces the correct failure message' do
          controller = controller_with_store('any key' => 'any value')
          expected_message = %<Expected #{controller.class} not to set any key in #{store_name}, but it did>
          assertion = proc do
            expect(controller).not_to set_store
          end

          expect(&assertion).to fail_with_message(expected_message)
        end
      end
    end
  end

  context 'with #[]' do
    it 'produces the right description' do
      matcher = set_store['the key']
      expected_description = %<should set #{store_name}["the key"]>

      expect(matcher.description).to eq expected_description
    end

    context 'in the positive' do
      context 'if the given key is present in the store' do
        it 'accepts the param as a string' do
          controller = controller_with_store('the_key' => 'any value')
          expect(controller).to set_store['the_key']
        end

        it 'accepts the param as a symbol' do
          controller = controller_with_store('the_key' => 'any value')
          expect(controller).to set_store[:the_key]
        end
      end

      context 'if the given key is not present in the store' do
        it 'rejects' do
          controller = controller_with_empty_store
          expect(controller).not_to set_store['the key']
        end

        it 'produces the correct failure message' do
          controller = controller_with_empty_store
          expected_message = %<Expected #{controller.class} to set #{store_name}["the key"], but it did not>
          assertion = proc do
            expect(controller).to set_store['the key']
          end

          expect(&assertion).to fail_with_message(expected_message)
        end
      end
    end

    context 'in the negative' do
      context 'if the given key is present in the store' do
        it 'produces the correct failure message' do
          controller = controller_with_store('the key' => 'any value')
          expected_message = %<Expected #{controller.class} not to set #{store_name}["the key"], but it did>
          assertion = proc do
            expect(controller).not_to set_store['the key']
          end

          expect(&assertion).to fail_with_message(expected_message)
        end
      end
    end
  end

  context 'with #to' do
    context 'given a static value' do
      it 'produces the right description' do
        matcher = set_store.to('the value')
        expected_description = %<should set any key in #{store_name} to "the value">

        expect(matcher.description).to eq expected_description
      end

      context 'in the positive' do
        context 'if the given value is present in the store' do
          it 'accepts' do
            controller = controller_with_store('any key' => 'the value')
            expect(controller).to set_store.to('the value')
          end

          it 'accepts given a value of nil' do
            controller = controller_with_store('any key' => nil)
            expect(controller).to set_store.to(nil)
          end

          it 'accepts given a value of false' do
            controller = controller_with_store('any key' => false)
            expect(controller).to set_store.to(false)
          end
        end

        context 'if the given value is not present in the store' do
          it 'rejects' do
            controller = controller_with_empty_store
            expect(controller).not_to set_store.to('the value')
          end

          it 'rejects checking for nil' do
            controller = controller_with_empty_store
            expect(controller).not_to set_store.to(nil)
          end

          it 'produces the correct failure message' do
            controller = controller_with_empty_store
            expected_message = %<Expected #{controller.class} to set any key in #{store_name} to "the value", but it did not>
            assertion = proc do
              expect(controller).to set_store.to('the value')
            end

            expect(&assertion).to fail_with_message(expected_message)
          end
        end
      end

      context 'in the negative' do
        context 'if the given value is present in the store' do
          it 'produces the correct failure message' do
            controller = controller_with_store('any key' => 'the value')
            expected_message = %<Expected #{controller.class} not to set any key in #{store_name} to "the value", but it did>
            assertion = proc do
              expect(controller).not_to set_store.to('the value')
            end

            expect(&assertion).to fail_with_message(expected_message)
          end
        end
      end
    end

    context 'given a regexp' do
      it 'produces the right description' do
        matcher = set_store.to(/value/)
        expected_description = %<should set any key in #{store_name} to a value matching /value/>

        expect(matcher.description).to eq expected_description
      end

      context 'in the positive' do
        context 'if the given value is present in the store' do
          it 'accepts' do
            controller = controller_with_store('any key' => 'the value')
            expect(controller).to set_store.to(/value/)
          end

          it 'accepts given a value of nil' do
            controller = controller_with_store('any key' => nil)
            expect(controller).to set_store.to(nil)
          end

          it 'accepts given a value of false' do
            controller = controller_with_store('any key' => false)
            expect(controller).to set_store.to(false)
          end
        end

        context 'if the given value is not present in the store' do
          it 'rejects' do
            controller = controller_with_empty_store
            expect(controller).not_to set_store.to(/value/)
          end

          it 'produces the correct failure message' do
            controller = controller_with_empty_store
            expected_message = %<Expected #{controller.class} to set any key in #{store_name} to a value matching /value/, but it did not>
            assertion = proc do
              expect(controller).to set_store.to(/value/)
            end

            expect(&assertion).to fail_with_message(expected_message)
          end
        end
      end

      context 'in the negative' do
        context 'if the given value is present in the store' do
          it 'produces the correct failure message' do
            controller = controller_with_store('any key' => 'the value')
            expected_message = %<Expected #{controller.class} not to set any key in #{store_name} to a value matching /value/, but it did>
            assertion = proc do
              expect(controller).not_to set_store.to(/value/)
            end

            expect(&assertion).to fail_with_message(expected_message)
          end
        end
      end
    end
  end

  context 'with #[] + #to' do
    context 'given a static value' do
      it 'produces the right description' do
        expected_description = %<should set #{store_name}["the key"] to "the value">
        matcher = set_store['the key'].to('the value')

        expect(matcher.description).to eq expected_description
      end

      context 'in the positive' do
        context 'if the given value is present in the store' do
          it 'accepts' do
            controller = controller_with_store('the key' => 'the value')
            expect(controller).to set_store['the key'].to('the value')
          end
        end

        context 'if the given value is not present in the store' do
          it 'rejects' do
            controller = controller_with_empty_store
            expect(controller).not_to set_store['the key'].to('the value')
          end

          it 'produces the correct failure message' do
            controller = controller_with_empty_store
            expected_message = %<Expected #{controller.class} to set #{store_name}["the key"] to "the value", but it did not>
            assertion = proc do
              expect(controller).to set_store['the key'].to('the value')
            end

            expect(&assertion).to fail_with_message(expected_message)
          end
        end
      end

      context 'in the negative' do
        context 'if the given value is present in the store' do
          it 'produces the correct failure message' do
            controller = controller_with_store('the key' => 'the value')
            expected_message = %<Expected #{controller.class} not to set #{store_name}["the key"] to "the value", but it did>
            assertion = proc do
              expect(controller).not_to set_store['the key'].to('the value')
            end

            expect(&assertion).to fail_with_message(expected_message)
          end
        end
      end
    end

    context 'given a dynamic value' do
      it 'produces the right description' do
        context = double('context', method_in_context: 'the value')
        matcher = set_store['the key'].
          in_context(context).
          to { method_in_context }
        expected_description = %<should set #{store_name}["the key"] to "the value">

        expect(matcher.description).to eq expected_description
      end

      context 'in the positive' do
        context 'if the value evaluated in the context is present in the store' do
          it 'accepts' do
            controller = controller_with_store('the key' => 'the value')
            context = double('context', method_in_context: 'the value')

            expect(controller).to set_store['the key'].
              in_context(context).
              to { method_in_context }
          end
        end

        context 'if the value evaluated in the context is not present in the store' do
          it 'rejects' do
            controller = controller_with_empty_store
            context = double('context', method_in_context: 'the value')

            expect(controller).not_to set_store['the key'].
              in_context(context).
              to { method_in_context }
          end

          it 'produces the correct failure message' do
            controller = controller_with_empty_store
            context = double('context', method_in_context: 'the value')
            expected_message = %<Expected #{controller.class} to set #{store_name}["the key"] to "the value", but it did not>
            assertion = proc do
              expect(controller).to set_store['the key'].
                in_context(context).
                to { method_in_context }
            end

            expect(&assertion).to fail_with_message(expected_message)
          end
        end
      end

      context 'in the negative' do
        context 'if the value evaluated in the context is present in the store' do
          it 'produces the correct failure message' do
            context = double('context', method_in_context: 'the value')
            controller = controller_with_store('the key' => 'the value')
            expected_message = %<Expected #{controller.class} not to set #{store_name}["the key"] to "the value", but it did>
            assertion = proc do
              expect(controller).not_to set_store['the key'].
                in_context(context).
                to { method_in_context }
            end

            expect(&assertion).to fail_with_message(expected_message)
          end
        end
      end
    end
  end

  def controller_with_empty_store
    build_fake_response
  end

  def controller_with_store(store_contents)
    context = self

    build_fake_response do
      store = context.store_within(self)

      store_contents.each do |key, value|
        store[key] = value
      end
    end
  end
end
