require 'spec_helper'

describe Shoulda::Matchers::Independent::DelegateMatcher do
  describe '#description' do
    context 'by default' do
      it 'states that it should delegate method to the right object' do
        matcher = delegate_method(:method_name).to(:target)

        expect(matcher.description)
          .to eq 'delegate method #method_name to :target'
      end
    end

    context 'with #as chain' do
      it 'states that it should delegate method to the right object and method' do
        matcher = delegate_method(:method_name).to(:target).as(:alternate)
        message = 'delegate method #method_name to :target as #alternate'

        expect(matcher.description).to eq message
      end
    end

    context 'with #with_argument chain' do
      it 'states that it should delegate method to the right object with right argument' do
        matcher = delegate_method(:method_name).to(:target)
          .with_arguments(:foo, bar: [1, 2])
        message = 'delegate method #method_name to :target with arguments: [:foo, {:bar=>[1, 2]}]'

        expect(matcher.description).to eq message
      end
    end
  end

  it 'raises an error if no delegation target is defined' do
    expect {
      delegate_method(:name).matches?(Object.new)
    }.to raise_exception described_class::TargetNotDefinedError
  end

  it 'raises an error if called with #should_not' do
    expect {
      delegate_method(:name).to(:anyone).does_not_match?(Object.new)
    }.to raise_exception described_class::InvalidDelegateMatcher
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
      matcher = delegate_method(:deliver_mail).to(:mailman)

      expect(matcher.matches?(post_office)).to be false
    end

    it 'has a failure message that indicates which method should have been delegated' do
      post_office = PostOffice.new
      message = 'Expected PostOffice#deliver_mail to delegate to PostOffice#mailman'

      expect {
        expect(post_office).to delegate_method(:deliver_mail).to(:mailman)
      }.to fail_with_message(message)
    end

    it 'uses the proper syntax for class methods in errors' do
      message = 'Expected PostOffice.deliver_mail to delegate to PostOffice.mailman'

      expect {
        expect(PostOffice).to delegate_method(:deliver_mail).to(:mailman)
      }.to fail_with_message(message)
    end
  end

  context 'given a method that delegates properly' do
    it 'accepts' do
      define_class(:mailman)

      define_class(:post_office) do
        def deliver_mail
          mailman.deliver_mail
        end

        def mailman
          Mailman.new
        end
      end

      post_office = PostOffice.new

      expect(post_office).to delegate_method(:deliver_mail).to(:mailman)
    end
  end

  context 'given a method that delegates properly with arguments' do
    let(:post_office) { PostOffice.new }

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
        expect(post_office).to delegate_method(:deliver_mail)
          .to(:mailman).with_arguments('221B Baker St.', hastily: true)
      end
    end

    context 'when not given the correct arguments' do
      it 'rejects' do
        matcher = delegate_method(:deliver_mail).to(:mailman)
          .with_arguments('123 Nowhere Ln.')

        expect(matcher.matches?(post_office)).to be_false
      end

      it 'has a failure message that indicates which arguments were expected' do
        message = 'Expected PostOffice#deliver_mail to delegate to PostOffice#mailman with arguments: ["123 Nowhere Ln."]'

        expect {
          expect(post_office).to delegate_method(:deliver_mail)
            .to(:mailman).with_arguments('123 Nowhere Ln.')
        }.to fail_with_message(message)
      end
    end
  end

  context 'given a method that delegates properly to a method of a different name' do
    let(:post_office) { PostOffice.new }

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
        expect(post_office).to delegate_method(:deliver_mail)
          .to(:mailman).as(:deliver_mail_and_avoid_dogs)
      end
    end

    context 'when given an incorrect method name' do
      it 'rejects' do
        matcher = delegate_method(:deliver_mail).to(:mailman).as(:watch_tv)

        expect(matcher.matches?(post_office)).to be_false
      end

      it 'has a failure message that indicates which method was expected' do
        message = 'Expected PostOffice#deliver_mail to delegate to PostOffice#mailman as #watch_tv'

        expect {
          expect(post_office).to delegate_method(:deliver_mail)
            .to(:mailman).as(:watch_tv)
        }.to fail_with_message(message)
      end
    end
  end
end
