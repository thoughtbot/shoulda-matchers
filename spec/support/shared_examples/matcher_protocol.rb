require 'spec_helper'

shared_examples 'a matcher' do

  it 'implements the matches? method' do
    subject.should respond_to(:matches?).with(1).arguments
  end

  it 'implements the failure_message method' do
    subject.should respond_to(:failure_message_for_should).with(0).arguments
  end

  it 'implements the negative_failure_message method' do
    subject.should respond_to(:failure_message_for_should_not).with(0).arguments
  end

  it 'implements the description method' do
    subject.should respond_to(:description).with(0).arguments
  end
end
