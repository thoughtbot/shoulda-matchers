require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::DisallowValueMatcher do
  it 'does not allow any types' do
    matcher('abcde').allowed_types.should == ''
  end

  context 'an attribute with a format validation' do
    it 'does not match if the value is allowed' do
      validating_format(:with => /abc/).should_not matcher('abcde').for(:attr)
    end

    it 'matches if the value is not allowed' do
      validating_format(:with => /abc/).should matcher('xyz').for(:attr)
    end
  end

  context 'an attribute with a format validation and a custom message' do
    it 'does not match if the value and message are both correct' do
      validating_format(:with => /abc/, :message => 'good message').
        should_not matcher('abcde').for(:attr).with_message('good message')
    end

    it "delegates its failure message to its allow matcher's negative failure message" do
      allow_matcher = stub_everything(:failure_message_for_should_not => 'allow matcher failure')
      Shoulda::Matchers::ActiveModel::AllowValueMatcher.stubs(:new).returns(allow_matcher)

      matcher = matcher('abcde').for(:attr).with_message('good message')
      matcher.matches?(validating_format(:with => /abc/, :message => 'good message'))

      matcher.failure_message_for_should.should == 'allow matcher failure'
    end

    it 'matches if the message is correct but the value is not' do
      validating_format(:with => /abc/, :message => 'good message').
        should matcher('xyz').for(:attr).with_message('good message')
    end
  end

  def matcher(value)
    described_class.new(value)
  end
end
