require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::DisallowValueMatcher do
  it 'does not allow any types' do
    matcher('abcde').allowed_types.should eq ''
  end

  context 'an attribute with a format validation' do
    it 'does not match if the value is allowed' do
      validating_format(:with => /abc/).should_not matcher('abcde').for(:attr)
    end

    it 'matches if the value is not allowed' do
      validating_format(:with => /abc/).should matcher('xyz').for(:attr)
    end
  end

  context "an attribute with a context-dependent validation" do
    context "without the validation context" do
      it "does not match" do
        validating_format(:with => /abc/, :on => :customisable).should_not matcher("xyz").for(:attr)
      end
    end

    context "with the validation context" do
      it "disallows a bad value" do
        validating_format(:with => /abc/, :on => :customisable).should matcher("xyz").for(:attr).on(:customisable)
      end

      it "does not match a good value" do
        validating_format(:with => /abc/, :on => :customisable).should_not matcher("abcde").for(:attr).on(:customisable)
      end
    end
  end

  context 'an attribute with a format validation and a custom message' do
    it 'does not match if the value and message are both correct' do
      validating_format(:with => /abc/, :message => 'good message').
        should_not matcher('abcde').for(:attr).with_message('good message')
    end

    it "delegates its failure message to its allow matcher's negative failure message" do
      allow_matcher = stub_everything(:failure_message_when_negated => 'allow matcher failure')
      Shoulda::Matchers::ActiveModel::AllowValueMatcher.stubs(:new).returns(allow_matcher)

      matcher = matcher('abcde').for(:attr).with_message('good message')
      matcher.matches?(validating_format(:with => /abc/, :message => 'good message'))

      matcher.failure_message.should eq 'allow matcher failure'
    end

    it 'matches if the message is correct but the value is not' do
      validating_format(:with => /abc/, :message => 'good message').
        should matcher('xyz').for(:attr).with_message('good message')
    end
  end

  context 'an attribute where the message occurs on another attribute' do
    it 'matches if the message is correct but the value is not' do
      record_with_custom_validation.should \
        matcher('bad value').for(:attr).with_message(/some message/, :against => :attr2)
    end

    it 'does not match if the value and message are both correct' do
      record_with_custom_validation.should_not \
        matcher('good value').for(:attr).with_message(/some message/, :against => :attr2)
    end

    def record_with_custom_validation
      define_model :example, :attr => :string, :attr2 => :string do
        validate :custom_validation

        def custom_validation
          if self[:attr] != 'good value'
            self.errors[:attr2] << 'some message'
          end
        end
      end.new
    end
  end

  def matcher(value)
    described_class.new(value)
  end
end
