require 'spec_helper'

shared_examples 'a numerical submatcher' do
  it 'implements the with_message method' do
    subject.should respond_to(:with_message).with(1).arguments
  end

  it 'implements the allowed_types method' do
    subject.should respond_to(:allowed_types).with(0).arguments
  end

  it 'implements the matches? method' do
    subject.should respond_to(:matches?).with(1).arguments
  end

  it 'implements the failure_message_for_should method' do
    subject.should respond_to(:failure_message_for_should).with(0).arguments
  end

  it 'implements the failure_message_for_should_not method' do
    subject.should respond_to(:failure_message_for_should_not).with(0).arguments
  end
end
