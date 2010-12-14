require 'spec_helper'

describe Shoulda::ActionMailer::HaveSentEmailMatcher do
  def add_mail_to_deliveries
    ::ActionMailer::Base.deliveries << Mailer.the_email
  end

  context "an email" do
    before do
      define_mailer :mailer, [:the_email] do
        def the_email
          mail :from    => "do-not-reply@example.com",
               :to      => "myself@me.com",
               :subject => "This is spam",
               :body    => "Every email is spam."
        end
      end
      add_mail_to_deliveries
    end

    after { ::ActionMailer::Base.deliveries.clear }

    it "should accept based on the subject" do
      should have_sent_email.with_subject(/is spam$/)
      matcher = have_sent_email.with_subject(/totally safe/)
      matcher.matches?(nil)
      matcher.failure_message.should =~ /Expected sent email with subject/
    end

    it "should accept based on a string sender" do
      should have_sent_email.from('do-not-reply@example.com')
      matcher = have_sent_email.from('you@example.com')
      matcher.matches?(nil)
      matcher.failure_message.should =~ /Expected sent email from/
    end

    it "should accept based on a regexp sender" do
      should have_sent_email.from(/@example\.com/)
      matcher = have_sent_email.from(/you@/)
      matcher.matches?(nil)
      matcher.failure_message.should =~ /Expected sent email from/
    end

    it "should accept based on the body" do
      should have_sent_email.with_body(/is spam\./)
      matcher = have_sent_email.with_body(/totally safe/)
      matcher.matches?(nil)
      matcher.failure_message.should =~ /Expected sent email with body/
    end

    it "should accept based on the recipient" do
      should have_sent_email.to('myself@me.com')
      matcher = have_sent_email.to('you@example.com')
      matcher.matches?(nil)
      matcher.failure_message.should =~ /Expected sent email to/
    end

    it "should list all deliveries within failure message" do
      add_mail_to_deliveries

      matcher = have_sent_email.to('you@example.com')
      matcher.matches?(nil)
      matcher.failure_message.should =~ /Deliveries:\n"This is spam" to \["myself@me\.com"\]\n"This is spam" to \["myself@me\.com"\]/
    end

    it "should chain" do
      should have_sent_email.with_subject(/spam/).from('do-not-reply@example.com').with_body(/spam/).to('myself@me.com')
      should_not have_sent_email.with_subject(/ham/).from('you@example.com').with_body(/ham/).to('them@example.com')
    end
  end
end
