require 'spec_helper'

describe Shoulda::Matchers::ActionMailer::HaveSentEmailMatcher do
  def add_mail_to_deliveries
    ::ActionMailer::Base.deliveries << Mailer.the_email
  end

  context "an email without multiple parts" do
      before do
      define_mailer :mailer, [:the_email] do
        def the_email
          mail :from    => "do-not-reply@example.com",
               :to      => "myself@me.com",
               :body    => "Every email is spam",
               :subject => "This is spam"
        end
      end
      add_mail_to_deliveries
    end

    after { ::ActionMailer::Base.deliveries.clear }

    it "accepts sent-email when it is not multipart" do
      should_not have_sent_email.multipart
      matcher = have_sent_email.multipart(true)
      matcher.matches?(Mailer.the_email)
      matcher.failure_message.should =~ /Expected sent email being multipart/
    end

    it "matches the body with a regexp" do
      should have_sent_email.with_body(/email is spam/)
    end

    it "matches the body with a string" do
      should have_sent_email.with_body("Every email is spam")
      should_not have_sent_email.with_body("emails is")
    end
  end

  context "an email with both a text/plain and text/html part" do
    before do
      define_mailer :mailer, [:the_email] do
        def the_email
          mail :from    => "do-not-reply@example.com",
               :to      => "myself@me.com",
               :subject => "This is spam" do |format|

            format.text { render :text => "Every email is spam." }
            format.html { render :text => "<h1>HTML is spam.</h1><p>Notably.</p>" }
          end
        end
      end
      add_mail_to_deliveries
    end

    after { ::ActionMailer::Base.deliveries.clear }

    it "accepts sent e-mail based on the subject" do
      should have_sent_email.with_subject(/is spam$/)
      matcher = have_sent_email.with_subject(/totally safe/)
      matcher.matches?(nil)
      matcher.failure_message.should =~ /Expected sent email with subject/
    end

    it "accepts sent e-mail based on a string sender" do
      should have_sent_email.from('do-not-reply@example.com')
      matcher = have_sent_email.from('you@example.com')
      matcher.matches?(nil)
      matcher.failure_message.should =~ /Expected sent email from/
    end

    it "accepts sent e-mail based on a regexp sender" do
      should have_sent_email.from(/@example\.com/)
      matcher = have_sent_email.from(/you@/)
      matcher.matches?(nil)
      matcher.failure_message.should =~ /Expected sent email from/
    end

    it "accepts sent e-mail based on the body" do
      should have_sent_email.with_body(/is spam\./)
      matcher = have_sent_email.with_body(/totally safe/)
      matcher.matches?(nil)
      matcher.failure_message.should =~ /Expected sent email with body/
    end

    it "accepts sent e-mail based on a text/plain part" do
      should have_sent_email.with_part('text/plain', /is spam\./)
      matcher = have_sent_email.with_part('text/plain', /HTML is spam/)
      matcher.matches?(nil)
      matcher.failure_message.should =~ /Expected sent email with a text\/plain part containing/
    end

    it "accepts sent e-mail based on a text/html part" do
      should have_sent_email.with_part('text/html', /HTML is spam/)
      matcher = have_sent_email.with_part('text/html', /HTML is not spam\./)
      matcher.matches?(nil)
      matcher.failure_message.should =~ /Expected sent email with a text\/html part containing/
    end

    it "accept sent e-mail based on the recipient" do
      should have_sent_email.to('myself@me.com')
      matcher = have_sent_email.to('you@example.com')
      matcher.matches?(nil)
      matcher.failure_message.should =~ /Expected sent email to/
    end

    it "accepts sent-email when it is multipart" do
      should have_sent_email.multipart
      matcher = have_sent_email.multipart(false)
      matcher.matches?(nil)
      matcher.failure_message.should =~ /Expected sent email not being multipart/
    end

    it "lists all the deliveries within failure message" do
      add_mail_to_deliveries

      matcher = have_sent_email.to('you@example.com')
      matcher.matches?(nil)
      matcher.failure_message.should =~ /Deliveries:\n"This is spam" to \["myself@me\.com"\]\n"This is spam" to \["myself@me\.com"\]/
    end

    it "allows chaining" do
      should have_sent_email.with_subject(/spam/).from('do-not-reply@example.com').with_body(/spam/).
        with_part('text/plain', /is spam\./).with_part('text/html', /HTML is spam/).to('myself@me.com')
      should_not have_sent_email.with_subject(/ham/).from('you@example.com').with_body(/ham/).
        with_part('text/plain', /is ham/).with_part('text/html', /HTML is ham/).to('them@example.com')
    end
  end

  it "provides a detailed description of the e-mail expected to be sent" do
    matcher = have_sent_email
    matcher.description.should == 'send an email'
    matcher = matcher.with_subject("Welcome!")
    matcher.description.should == 'send an email with a subject of "Welcome!"'
    matcher = matcher.with_body("Welcome, human!")
    matcher.description.should == 'send an email with a subject of "Welcome!" containing "Welcome, human!"'
    matcher = matcher.with_part('text/plain', 'plain')
    matcher.description.should == 'send an email with a subject of "Welcome!" containing "Welcome, human!" having a text/plain part containing "plain"'
    matcher = matcher.with_part('text/html', 'html')
    matcher.description.should == 'send an email with a subject of "Welcome!" containing "Welcome, human!" having a text/plain part containing "plain" having a text/html part containing "html"'
    matcher = matcher.from("alien@example.com")
    matcher.description.should == 'send an email with a subject of "Welcome!" containing "Welcome, human!" having a text/plain part containing "plain" having a text/html part containing "html" from "alien@example.com"'
    matcher = matcher.to("human@example.com")
    matcher.description.should == 'send an email with a subject of "Welcome!" containing "Welcome, human!" having a text/plain part containing "plain" having a text/html part containing "html" from "alien@example.com" to "human@example.com"'
  end
end
