require 'spec_helper'

describe Shoulda::Matchers::ActionMailer::HaveSentEmailMatcher do
  def add_mail_to_deliveries(params = nil)
    ::ActionMailer::Base.deliveries << Mailer.the_email(params)
  end

  context "testing with instance variables" do
    before do
      @info = {
      :from => "do-not-reply@example.com",
      :to => "myself@me.com",
      :cc => ["you@you.com", "joe@bob.com", "hello@goodbye.com"],
      :bcc => ["test@example.com", "sam@bob.com", "goodbye@hello.com"],
      :subject => "This is spam",
      :body => "Every email is spam." }

      define_mailer :mailer, [:the_email] do
        def the_email(params)
          mail params
        end
      end
      add_mail_to_deliveries(@info)
    end

    after { ::ActionMailer::Base.deliveries.clear }

    it "should send an e-mail based on subject" do
      should have_sent_email.with_subject{ @info[:subject] }
    end

    it "should send an e-mail based on recipient" do
      should have_sent_email.to{ @info[:to] }
    end

    it "should send an e-mail based on sender" do
      should have_sent_email.from{ @info[:from] }
    end

    it "should send an e-mail based on cc" do
      should have_sent_email.cc{ @info[:cc][0] }
    end

    it "should send an e-mail based on cc list" do
      should have_sent_email.with_cc{ @info[:cc] }
    end

    it "should send an e-mail based on bcc" do
      should have_sent_email.bcc{ @info[:bcc][0] }
    end

    it "should send an e-mail based on bcc list" do
      should have_sent_email.with_bcc{ @info[:bcc] }
    end

    it "should send an e-mail based on body" do
      should have_sent_email.with_body{ @info[:body] }
    end
  end

  context "an email" do
    before do
      define_mailer :mailer, [:the_email] do
        def the_email(params)
          mail :from    => "do-not-reply@example.com",
               :to      => "myself@me.com",
               :subject => "This is spam",
               :cc      => ["you@you.com", "joe@bob.com", "hello@goodbye.com"],
               :bcc     => ["test@example.com", "sam@bob.com", "goodbye@hello.com"],
               :body    => "Every email is spam."
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

    it "accepts sent e-mail based on the recipient" do
      should have_sent_email.to('myself@me.com')
      matcher = have_sent_email.to('you@example.com')
      matcher.matches?(nil)
      matcher.failure_message.should =~ /Expected sent email to/
    end

    it "accepts sent e-mail based on cc string" do
      should have_sent_email.cc('joe@bob.com')
      matcher = have_sent_email.cc('you@example.com')
      matcher.matches?(nil)
      matcher.failure_message.should =~ /Expected sent email cc/
    end

    it "accepts sent-email based on cc regex" do
      should have_sent_email.cc(/@bob\.com/)
      matcher = have_sent_email.cc(/us@/)
      matcher.matches?(nil)
      matcher.failure_message.should =~ /Expected sent email cc/
    end

    it "accepts sent e-mail based on cc list" do
      should have_sent_email.with_cc(['you@you.com', 'joe@bob.com'])
      matcher = have_sent_email.with_cc(['you@example.com'])
      matcher.matches?(nil)
      matcher.failure_message.should =~ /Expected sent email with cc/
    end

    it "accepts sent e-mail based on bcc string" do
      should have_sent_email.bcc("goodbye@hello.com")
      matcher = have_sent_email.bcc("test@hello.com")
      matcher.matches?(nil)
      matcher.failure_message.should =~ /Expected sent email bcc/
    end

    it "accepts sent e-mail based on bcc regex" do
      should have_sent_email.bcc(/@example\.com/)
      matcher = have_sent_email.bcc(/you@/)
      matcher.matches?(nil)
      matcher.failure_message.should =~ /Expected sent email bcc/
    end

    it "accepts sent e-mail based on bcc list" do
      should have_sent_email.with_bcc(['sam@bob.com', 'test@example.com'])
      matcher = have_sent_email.with_bcc(['you@you.com', 'joe@bob.com'])
      matcher.matches?(nil)
      matcher.failure_message.should =~ /Expected sent email with bcc/
    end

    it "lists all the deliveries within failure message" do
      add_mail_to_deliveries

      matcher = have_sent_email.to('you@example.com')
      matcher.matches?(nil)
      matcher.failure_message.should =~ /Deliveries:\n"This is spam" to \["myself@me\.com"\]\n"This is spam" to \["myself@me\.com"\]/
    end

    it "allows chaining" do
      should have_sent_email.with_subject(/spam/).from('do-not-reply@example.com').with_body(/spam/).to('myself@me.com')
      should_not have_sent_email.with_subject(/ham/).from('you@example.com').with_body(/ham/).to('them@example.com')
    end
  end

  it "provides a detailed description of the e-mail expected to be sent" do
    matcher = have_sent_email
    matcher.description.should == 'send an email'
    matcher = matcher.with_subject("Welcome!")
    matcher.description.should == 'send an email with a subject of "Welcome!"'
    matcher = matcher.with_body("Welcome, human!")
    matcher.description.should == 'send an email with a subject of "Welcome!" containing "Welcome, human!"'
    matcher = matcher.from("alien@example.com")
    matcher.description.should == 'send an email with a subject of "Welcome!" containing "Welcome, human!" from "alien@example.com"'
    matcher = matcher.to("human@example.com")
    matcher.description.should == 'send an email with a subject of "Welcome!" containing "Welcome, human!" from "alien@example.com" to "human@example.com"'
  end
end
