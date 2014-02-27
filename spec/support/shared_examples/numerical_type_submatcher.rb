require 'spec_helper'

shared_examples 'a numerical type submatcher' do
  it 'implements the allowed_type method' do
    expect(subject).to respond_to(:allowed_type).with(0).arguments
    expect { subject.allowed_type }.not_to raise_error
  end

  it 'implements the diff_to_compare' do
    expect(subject).to respond_to(:diff_to_compare).with(0).arguments
    expect { subject.diff_to_compare }.not_to raise_error
  end

  it 'returns itself when given a message' do
    expect(subject.with_message('some message')).to eq subject
  end
end
