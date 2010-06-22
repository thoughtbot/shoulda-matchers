require 'test_helper'

class HaveSentEmailTest < ActiveSupport::TestCase # :nodoc:
  def add_mail_to_deliveries
    if defined?(AbstractController::Rendering)
      ::ActionMailer::Base.deliveries << Mailer.the_email
    else
      ::ActionMailer::Base.deliveries << Mailer.create_the_email
    end
  end

  context "an email" do
    setup do
      define_mailer :mailer, [:the_email] do
        def the_email
          if defined?(AbstractController::Rendering)
            mail :from    => "do-not-reply@example.com",
                 :to      => "myself@me.com",
                 :subject => "This is spam",
                 :body    => "Every email is spam."
          else
            from       "do-not-reply@example.com"
            recipients "myself@me.com"
            subject    "This is spam"
            body       "Every email is spam."
          end
        end
      end
      add_mail_to_deliveries
    end

    teardown { ::ActionMailer::Base.deliveries.clear }

    should "accept based on the subject" do
      assert_accepts have_sent_email.with_subject(/is spam$/), nil
      assert_rejects have_sent_email.with_subject(/totally safe/), nil,
                     :message => /Expected sent email with subject/
    end

    should "accept based on the sender" do
      assert_accepts have_sent_email.from('do-not-reply@example.com'), nil
      assert_rejects have_sent_email.from('you@example.com'), nil,
                     :message => /Expected sent email from/
    end

    should "accept based on the body" do
      assert_accepts have_sent_email.with_body(/is spam\./), nil
      assert_rejects have_sent_email.with_body(/totally safe/), nil,
                     :message => /Expected sent email with body/
    end

    should "accept based on the recipient" do
      assert_accepts have_sent_email.to('myself@me.com'), nil
      assert_rejects have_sent_email.to('you@example.com'), nil,
                     :message => /Expected sent email to/
    end

    should "list all deliveries within failure message" do
      add_mail_to_deliveries

      assert_rejects have_sent_email.to('you@example.com'), nil,
                                        :message => /Deliveries:\n"This is spam" to \["myself@me\.com"\]\n"This is spam" to \["myself@me\.com"\]/
    end

    should "chain" do
      assert_accepts have_sent_email.with_subject(/spam/).from('do-not-reply@example.com').with_body(/spam/).to('myself@me.com'), nil
      assert_rejects have_sent_email.with_subject(/ham/).from('you@example.com').with_body(/ham/).to('them@example.com'), nil
    end
  end
end
