require 'spec_helper'

describe Shoulda::Matchers::Independent::DelegateMethodMatcher do
  describe '#description' do
    context 'against an instance' do
      subject { Object.new }

      context 'by default' do
        it 'states that it should delegate method to the right object' do
          matcher = delegate_method(:method_name).to(:target)

          expect(matcher.description).
            to eq 'delegate #method_name to #target object'
        end
      end

      context 'with #as chain' do
        it 'states that it should delegate method to the right object and method' do
          matcher = delegate_method(:method_name).to(:target).as(:alternate)
          message = 'delegate #method_name to #target object as #alternate'

          expect(matcher.description).to eq message
        end
      end

      context 'with #with_argument chain' do
        it 'states that it should delegate method to the right object with right argument' do
          matcher = delegate_method(:method_name).to(:target).
            with_arguments(:foo, bar: [1, 2])
          message = 'delegate #method_name to #target object passing arguments [:foo, {:bar=>[1, 2]}]'

          expect(matcher.description).to eq message
        end
      end
    end

    context 'against a class' do
      subject { Object }

      context 'by default' do
        it 'states that it should delegate method to the right object' do
          matcher = delegate_method(:method_name).to(:target)

          expect(matcher.description).
            to eq 'delegate .method_name to .target object'
        end
      end

      context 'with #as chain' do
        it 'states that it should delegate method to the right object and method' do
          matcher = delegate_method(:method_name).to(:target).as(:alternate)
          message = 'delegate .method_name to .target object as .alternate'

          expect(matcher.description).to eq message
        end
      end

      context 'with #with_argument chain' do
        it 'states that it should delegate method to the right object with right argument' do
          matcher = delegate_method(:method_name).to(:target).
            with_arguments(:foo, bar: [1, 2])
          message = 'delegate .method_name to .target object passing arguments [:foo, {:bar=>[1, 2]}]'

          expect(matcher.description).to eq message
        end
      end
    end
  end

  it 'raises an error if the target method was never specified before matching' do
    expect {
      expect(Object.new).to delegate_method(:name)
    }.to raise_error described_class::TargetNotDefinedError
  end

  context 'stubbing an instance delegating method' do
    it 'only happens temporarily and is removed after the match' do
      define_class(:company) do
        def name
          'Acme Company'
        end
      end

      define_class(:person) do
        def company_name
          company.name
        end

        def company
          Company.new
        end
      end

      person = Person.new
      matcher = delegate_method(:company_name).to(:company).as(:name)
      matcher.matches?(person)

      expect(person.company.name).to eq 'Acme Company'
    end
  end

  context 'given a method that does not delegate' do
    before do
      define_class(:post_office) do
        def deliver_mail
          :delivered
        end
      end
    end

    it 'rejects' do
      post_office = PostOffice.new
      expect(post_office).not_to delegate_method(:deliver_mail).to(:mailman)
    end

    it 'has a failure message that indicates which method should have been delegated' do
      post_office = PostOffice.new
      message = [
        'Expected PostOffice to delegate #deliver_mail to #mailman object',
        'Method calls sent to PostOffice#mailman: (none)'
      ].join("\n")

      expect {
        expect(post_office).to delegate_method(:deliver_mail).to(:mailman)
      }.to fail_with_message(message)
    end

    it 'uses the proper syntax for class methods in errors' do
      message = [
        'Expected PostOffice to delegate .deliver_mail to .mailman object',
        'Method calls sent to PostOffice.mailman: (none)'
      ].join("\n")

      expect {
        expect(PostOffice).to delegate_method(:deliver_mail).to(:mailman)
      }.to fail_with_message(message)
    end
  end

  context 'given a method that delegates properly' do
    before do
      define_class(:mailman)

      define_class(:post_office) do
        def deliver_mail
          mailman.deliver_mail
        end

        def mailman
          Mailman.new
        end
      end
    end

    it 'accepts' do
      post_office = PostOffice.new
      expect(post_office).to delegate_method(:deliver_mail).to(:mailman)
    end

    it 'produces the correct failure message if the assertion was negated' do
      post_office = PostOffice.new
      message = 'Expected PostOffice not to delegate #deliver_mail to #mailman object, but it did'

      expect {
        expect(post_office).not_to delegate_method(:deliver_mail).to(:mailman)
      }.to fail_with_message(message)
    end
  end

  context 'given a private method that delegates properly' do
    before do
      define_class(:mailman)

      define_class(:post_office) do
        def deliver_mail
          mailman.deliver_mail
        end

        def mailman
          Mailman.new
        end

        private :mailman
      end
    end

    it 'accepts' do
      post_office = PostOffice.new
      expect(post_office).to delegate_method(:deliver_mail).to(:mailman)
    end
  end

  context 'given a method that delegates properly with arguments' do
    before do
      define_class(:mailman)

      define_class(:post_office) do
        def deliver_mail(*args)
          mailman.deliver_mail('221B Baker St.', hastily: true)
        end

        def mailman
          Mailman.new
        end
      end
    end

    context 'when given the correct arguments' do
      it 'accepts' do
        post_office = PostOffice.new
        expect(post_office).to delegate_method(:deliver_mail).
          to(:mailman).with_arguments('221B Baker St.', hastily: true)
      end

      it 'produces the correct failure message if the assertion was negated' do
        post_office = PostOffice.new
        message = 'Expected PostOffice not to delegate #deliver_mail to #mailman object passing arguments ["221B Baker St.", {:hastily=>true}], but it did'

        expect {
          expect(post_office).
            not_to delegate_method(:deliver_mail).
            to(:mailman).
            with_arguments('221B Baker St.', hastily: true)
        }.to fail_with_message(message)
      end
    end

    context 'when not given the correct arguments' do
      it 'rejects' do
        post_office = PostOffice.new
        expect(post_office).
          not_to delegate_method(:deliver_mail).to(:mailman).
          with_arguments('123 Nowhere Ln.')
      end

      it 'has a failure message that indicates which arguments were expected' do
        post_office = PostOffice.new
        message = [
          'Expected PostOffice to delegate #deliver_mail to #mailman object passing arguments ["123 Nowhere Ln."]',
          'Method calls sent to PostOffice#mailman:',
          '1) deliver_mail("221B Baker St.", {:hastily=>true})'
        ].join("\n")

        expect {
          expect(post_office).to delegate_method(:deliver_mail).
            to(:mailman).with_arguments('123 Nowhere Ln.')
        }.to fail_with_message(message)
      end
    end
  end

  context 'given a method that delegates properly to a method of a different name' do
    before do
      define_class(:mailman)

      define_class(:post_office) do
        def deliver_mail
          mailman.deliver_mail_and_avoid_dogs
        end

        def mailman
          Mailman.new
        end
      end
    end

    context 'when given the correct method name' do
      it 'accepts' do
        post_office = PostOffice.new
        expect(post_office).to delegate_method(:deliver_mail).
          to(:mailman).as(:deliver_mail_and_avoid_dogs)
      end

      it 'produces the correct failure message if the assertion was negated' do
        post_office = PostOffice.new
        message = 'Expected PostOffice not to delegate #deliver_mail to #mailman object as #deliver_mail_and_avoid_dogs, but it did'

        expect {
          expect(post_office).
            not_to delegate_method(:deliver_mail).
            to(:mailman).
            as(:deliver_mail_and_avoid_dogs)
        }.to fail_with_message(message)
      end
    end

    context 'when given an incorrect method name' do
      it 'rejects' do
        post_office = PostOffice.new
        expect(post_office).
          not_to delegate_method(:deliver_mail).to(:mailman).as(:watch_tv)
      end

      it 'has a failure message that indicates which method was expected' do
        post_office = PostOffice.new
        message = [
          'Expected PostOffice to delegate #deliver_mail to #mailman object as #watch_tv',
          'Method calls sent to PostOffice#mailman:',
          '1) deliver_mail_and_avoid_dogs()'
        ].join("\n")

        expect {
          expect(post_office).to delegate_method(:deliver_mail).
            to(:mailman).as(:watch_tv)
        }.to fail_with_message(message)
      end
    end
  end
end
