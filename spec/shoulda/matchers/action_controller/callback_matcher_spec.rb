require 'spec_helper'

describe Shoulda::Matchers::ActionController::CallbackMatcher do
  shared_examples 'CallbackMatcher' do |kind, callback_type|
    let(:matcher) { described_class.new(:authenticate_user!, kind, callback_type) }
    let(:controller) { define_controller('HookController') }

    describe '#matches?' do
      it "matches when a #{kind} hook is in place" do
        add_callback(kind, callback_type, :authenticate_user!)

        expect(matcher.matches?(controller)).to be_true
      end

      it "does not match when a #{kind} hook is missing" do
        expect(matcher.matches?(controller)).to be_false
      end
    end

    describe 'description' do
      it 'includes the filter kind and name' do
        expect(matcher.description).to eq "have :authenticate_user! as a #{kind}_#{callback_type}"
      end
    end

    describe 'failure message' do
      it 'includes the filter kind and name that was expected' do
        message = "Expected that HookController would have :authenticate_user! as a #{kind}_#{callback_type}"

        expect {
          expect(controller).to send("use_#{kind}_#{callback_type}", :authenticate_user!)
        }.to fail_with_message(message)
      end
    end

    describe 'failure message when negated' do
      it 'includes the filter kind and name that was expected' do
        add_callback(kind, callback_type, :authenticate_user!)
        message = "Expected that HookController would not have :authenticate_user! as a #{kind}_#{callback_type}"

        expect {
          expect(controller).not_to send("use_#{kind}_#{callback_type}", :authenticate_user!)
        }.to fail_with_message(message)
      end
    end

    private

    def add_callback(kind, callback_type, callback)
      controller.send("#{kind}_#{callback_type}", callback)
    end
  end

  describe '#use_before_filter' do
    it_behaves_like 'CallbackMatcher', :before, :filter
  end

  describe '#use_after_filter' do
    it_behaves_like 'CallbackMatcher', :after, :filter
  end

  describe '#use_around_filter' do
    it_behaves_like 'CallbackMatcher', :around, :filter
  end

  if rails_4_x?
    describe '#use_before_action' do
      it_behaves_like 'CallbackMatcher', :before, :action
    end

    describe '#use_after_action' do
      it_behaves_like 'CallbackMatcher', :after, :action
    end

    describe '#use_around_action' do
      it_behaves_like 'CallbackMatcher', :around, :action
    end
  end
end
