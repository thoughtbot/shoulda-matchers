require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class HaveSentEmailTest < ActiveSupport::TestCase # :nodoc:
  context "an email" do
    setup do
      define_mailer :mailer, [:the_email] do
        def the_email
          from       "do-not-reply@example.com"
          recipients "myself@me.com"
          subject    "This is spam"
          body       :body => "Every email is spam."
        end
      end
      @mail = Mailer.create_the_email
    end

    should "accept based on the subject" do
      assert_accepts have_sent_email.with_subject(/is spam$/), @mail
      assert_rejects have_sent_email.with_subject(/totally safe/), @mail
    end

    should "accept based on the sender" do
      assert_accepts have_sent_email.from('do-not-reply@example.com'), @mail
      assert_rejects have_sent_email.from('you@example.com'), @mail
    end

    should "accept based on the body" do
      assert_accepts have_sent_email.with_body(/is spam\./), @mail
      assert_rejects have_sent_email.with_body(/totally safe/), @mail
    end

    should "accept baed on the recipienct" do
      assert_accepts have_sent_email.to('myself@me.com'), @mail
      assert_rejects have_sent_email.to('you@example.com'), @mail
    end

    should "chain" do
      assert_accepts have_sent_email.with_subject(/spam/).from('do-not-reply@example.com').with_body(/spam/).to('myself@me.com'), @mail
      assert_rejects have_sent_email.with_subject(/ham/).from('you@example.com').with_body(/ham/).to('them@example.com'), @mail
    end
  end
end
