require 'spec_helper'

describe Shoulda::Matchers::ActionMailer::HaveSentEmailMatcher do
  subject { Shoulda::Matchers::ActionMailer::HaveSentEmailMatcher.new(self) }

  def add_mail_to_deliveries(params = nil)
    ::ActionMailer::Base.deliveries << Mailer.the_email(params)
  end

  context "testing with instance variables with no multipart" do
    let(:info) do
      {
        :from => "do-not-reply@example.com",
        :reply_to => "reply-to-me@example.com",
        :to => "myself@me.com",
        :cc => ["you@you.com", "joe@bob.com", "hello@goodbye.com"],
        :bcc => ["test@example.com", "sam@bob.com", "goodbye@hello.com"],
        :subject => "This is spam",
        :body => "Every email is spam."
      }
    end

    before do
      define_mailer(:mailer, [:the_email]) do
        def the_email(params)
          mail params
        end
      end
      add_mail_to_deliveries(info)
    end

    after { ::ActionMailer::Base.deliveries.clear }

    it "should send an e-mail based on subject" do
      should have_sent_email.with_subject{ info[:subject] }
    end

    it "should send an e-mail based on recipient" do
      should have_sent_email.to(nil) { info[:to] }
    end

    it "should send an e-mail based on sender" do
      should have_sent_email.from{ info[:from] }
    end

    it "should send an e-email based on reply_to" do
      should have_sent_email.reply_to { info[:reply_to] }
    end

    it "should send an e-mail based on cc" do
      should have_sent_email.cc{ info[:cc][0] }
    end

    it "should send an e-mail based on cc list" do
      should have_sent_email.with_cc{ info[:cc] }
    end

    it "should send an e-mail based on bcc" do
      should have_sent_email.bcc{ info[:bcc][0] }
    end

    it "should send an e-mail based on bcc list" do
      should have_sent_email.with_bcc{ info[:bcc] }
    end

    it "should send an e-mail based on body" do
      should have_sent_email.with_body{ info[:body] }
    end
  end

  context "testing with instance variables with multiple parts" do
    let(:info) do
      {
        :from => "do-not-reply@example.com",
        :to => "myself@me.com",
        :cc => ["you@you.com", "joe@bob.com", "hello@goodbye.com"],
        :bcc => ["test@example.com", "sam@bob.com", "goodbye@hello.com"],
        :subject => "This is spam",
        :text => "Every email is spam.",
        :html => "<h1>HTML is spam.</h1><p>Notably.</p>"
      }
    end

    before do
      define_mailer(:mailer, [:the_email]) do
        def the_email(params)
          mail params do |format|
            format.text { render :text => params[:text] }
            format.html { render :text => params[:html] }
          end
        end
      end
      add_mail_to_deliveries(info)
    end

    after { ::ActionMailer::Base.deliveries.clear }

    it "should send emails with text and html parts" do
      should have_sent_email.with_part('text/plain') { info[:text] }.with_part('text/html') { info[:html] }
    end

    it "should have the block override the method argument" do
      should have_sent_email.with_part('text/plain', 'foo') { info[:text] }.with_part('text/html', /bar/) { info[:html] }
    end
  end

  context "an email without multiple parts" do
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

    it "accepts sent-email when it is not multipart" do
      should_not have_sent_email.multipart
      matcher = have_sent_email.multipart(true)
      matcher.matches?(Mailer.the_email(nil))
      matcher.failure_message.should =~ /Expected sent email being multipart/
    end

    it "matches the body with a regexp" do
      should have_sent_email.with_body(/email is spam/)
    end

    it "matches the body with a string" do
      should have_sent_email.with_body("Every email is spam.")
      should_not have_sent_email.with_body("emails is")
    end
  end

  context "an email with both a text/plain and text/html part" do
    before do
      define_mailer :mailer, [:the_email] do
        def the_email(params)
          mail :from    => "do-not-reply@example.com",
            :to      => "myself@me.com",
            :cc      => ["you@you.com", "joe@bob.com", "hello@goodbye.com"],
            :bcc     => ["test@example.com", "sam@bob.com", "goodbye@hello.com"],
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

  context "testing multiple email deliveries at once" do
    let(:info1) do
      {
        :from => "do-not-reply@example.com",
        :to => "one@me.com",
        :subject => "subject",
        :body => "body"
      }
    end

    let(:info2) do
      {
        :from => "do-not-reply@example.com",
        :to => "two@me.com",
        :subject => "subject",
        :body => "body"
      }
    end

    before do
      define_mailer(:mailer, [:the_email]) do
        def the_email(params)
          mail params
        end
      end
      add_mail_to_deliveries(info1)
      add_mail_to_deliveries(info2)
    end

    after { ::ActionMailer::Base.deliveries.clear }

    it "should send an e-mail based on recipient 1" do
      should have_sent_email.to("one@me.com")
    end

    it "should send an e-mail based on recipient 2" do
      should have_sent_email.to("two@me.com")
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
    matcher = matcher.reply_to("reply-to-me@example.com")
    matcher.description.should == 'send an email with a subject of "Welcome!" containing "Welcome, human!" having a text/plain part containing "plain" having a text/html part containing "html" from "alien@example.com" reply to "reply-to-me@example.com" to "human@example.com"'
  end
end
