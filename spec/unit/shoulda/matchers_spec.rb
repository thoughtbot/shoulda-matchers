require 'spec_helper'
require 'minitest'
require 'shoulda/matchers'

describe Shoulda::Matchers do
  describe '.assertion_exception_class' do
    around do |example|
      original = Shoulda::Matchers.instance_variable_get(:@assertion_exception_class)
      example.run
    ensure
      Shoulda::Matchers.instance_variable_set(:@assertion_exception_class, original)
    end

    context 'when not yet set (e.g. before integration has run)' do
      before do
        Shoulda::Matchers.instance_variable_set(:@assertion_exception_class, nil)
      end

      it 'falls back to Minitest::Assertion, rather than being nil' do
        expect(Shoulda::Matchers.assertion_exception_class).to eq(Minitest::Assertion)
      end

      it 'is usable directly in a rescue clause without raising TypeError' do
        # This is a regression test for the exact crash reported in
        # https://github.com/thoughtbot/shoulda-matchers/issues/1489:
        # `rescue Shoulda::Matchers.assertion_exception_class => e` used to
        # raise "TypeError: class or module required for rescue clause"
        # whenever assertion_exception_class was still nil (e.g. a matcher
        # ran before Shoulda::Matchers.configure's integration had set it).
        result =
          begin
            begin
              raise Minitest::Assertion, 'route not recognized'
            rescue Shoulda::Matchers.assertion_exception_class => e
              e.message
            end
          rescue TypeError => e
            "unexpectedly raised #{e.class}: #{e.message}"
          end

        expect(result).to eq('route not recognized')
      end
    end

    context 'when explicitly set (normal, integrated state)' do
      before do
        Shoulda::Matchers.assertion_exception_class = Minitest::Assertion
      end

      it 'returns the value that was set' do
        expect(Shoulda::Matchers.assertion_exception_class).to eq(Minitest::Assertion)
      end
    end
  end
end
