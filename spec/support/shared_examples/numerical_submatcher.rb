require 'spec_helper'

shared_examples 'a numerical submatcher' do
  it 'implements the with_message method' do
    expect(subject).to respond_to(:with_message).with(1).arguments
  end

  it 'implements the matches? method' do
    expect(subject).to respond_to(:matches?).with(1).arguments
  end

  it 'implements the failure_message method' do
    expect(subject).to respond_to(:failure_message).with(0).arguments
  end

  it 'implements the failure_message_when_negated method' do
    expect(subject).to respond_to(:failure_message_when_negated).with(0).arguments
  end
end
