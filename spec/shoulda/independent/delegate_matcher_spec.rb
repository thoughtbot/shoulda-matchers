require 'spec_helper'

describe Shoulda::Matchers::Independent::DelegateMatcher do
  it 'supports chaining on #to' do
    matcher = delegate_method(:method)
    matcher.to(:another_method).should == matcher
  end

  it 'supports chaining on #with_arguments' do
    matcher = delegate_method(:method)
    matcher.with_arguments(1, 2, 3).should == matcher
  end

  it 'supports chaining on #as' do
    matcher = delegate_method(:method)
    matcher.as(:some_other_method).should == matcher
  end

  it 'should raise an error if no delegation target is defined' do
    object = Object.new
    expect {
      object.should delegate_method(:name)
    }.to raise_exception Shoulda::Matchers::Independent::DelegateMatcher::TargetNotDefinedError
  end

  it 'should raise an error if called with #should_not' do
    object = Object.new
    expect {
      object.should_not delegate_method(:name).to(:anyone)
    }.to raise_exception Shoulda::Matchers::Independent::DelegateMatcher::InvalidDelegateMatcher
  end

  context 'given a method that does not delegate' do
    before do
      define_class(:post_office) do
        def deliver_mail
          :delivered
        end
      end
    end

    it 'does not match' do
      post_office = PostOffice.new
      matcher = delegate_method(:deliver_mail).to(:mailman)
      matcher.matches?(post_office).should be_false
    end

    it 'has a failure message that indicates which method should have been delegated' do
      post_office = PostOffice.new
      matcher = delegate_method(:deliver_mail).to(:mailman)

      matcher.matches?(post_office)

      message = 'Expected PostOffice#deliver_mail to delegate to PostOffice#mailman'
      matcher.failure_message.should == message
    end

    it 'uses the proper syntax for class methods in errors' do
      matcher = delegate_method(:deliver_mail).to(:mailman)

      matcher.matches?(PostOffice)

      message = 'Expected PostOffice.deliver_mail to delegate to PostOffice.mailman'
      matcher.failure_message.should == message
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

    it 'matches' do
      post_office = PostOffice.new
      post_office.should delegate_method(:deliver_mail).to(:mailman)
    end
  end

  context 'given a method that delegates properly with certain arguments' do
    before do
      define_class(:mailman)
      define_class(:post_office) do
        def deliver_mail
          mailman.deliver_mail('221B Baker St.', :hastily => true)
        end

        def mailman
          Mailman.new
        end
      end
    end

    context 'when given the correct arguments' do
      it 'matches' do
        post_office = PostOffice.new
        matcher = delegate_method(:deliver_mail).to(:mailman).with_arguments('221B Baker St.', :hastily => true)
        post_office.should matcher
      end
    end

    context 'when not given the correct arguments' do
      it 'does not match' do
        post_office = PostOffice.new
        matcher = delegate_method(:deliver_mail).to(:mailman).with_arguments('123 Nowhere Ln.')
        matcher.matches?(post_office).should be_false
      end

      it 'has a failure message that indicates which arguments were expected' do
        post_office = PostOffice.new
        matcher = delegate_method(:deliver_mail).to(:mailman).with_arguments('123 Nowhere Ln.')

        matcher.matches?(post_office)

        message = 'Expected PostOffice#deliver_mail to delegate to PostOffice#mailman with arguments: ["123 Nowhere Ln."]'
        matcher.failure_message.should == message
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
      it 'matches' do
        post_office = PostOffice.new
        matcher = delegate_method(:deliver_mail).to(:mailman).as(:deliver_mail_and_avoid_dogs)
        post_office.should matcher
      end
    end

    context 'when given an incorrect method name' do
      it 'does not match' do
        post_office = PostOffice.new
        matcher = delegate_method(:deliver_mail).to(:mailman).as(:watch_tv)
        matcher.matches?(post_office).should be_false
      end

      it 'has a failure message that indicates which method was expected' do
        post_office = PostOffice.new
        matcher = delegate_method(:deliver_mail).to(:mailman).as(:watch_tv)

        matcher.matches?(post_office)

        message = 'Expected PostOffice#deliver_mail to delegate to PostOffice#mailman as :watch_tv'
        matcher.failure_message.should == message
      end
    end
  end
end

describe Shoulda::Matchers::Independent::DelegateMatcher::TargetNotDefinedError do
  it 'has a useful message' do
    error = Shoulda::Matchers::Independent::DelegateMatcher::TargetNotDefinedError.new
    error.message.should include 'Delegation needs a target'
  end
end

describe Shoulda::Matchers::Independent::DelegateMatcher::InvalidDelegateMatcher do
  it 'has a useful message' do
    error = Shoulda::Matchers::Independent::DelegateMatcher::InvalidDelegateMatcher.new
    error.message.should include 'does not support #should_not'
  end
end
