require 'shoulda/action_mailer/matchers/have_sent_email'

module Shoulda # :nodoc:
  module ActionMailer # :nodoc:
    # = Matchers for your mailers
    #
    # This matcher will test that email is sent properly
    #
    #   describe User do
    #     it { should have_sent_email.with_subject(/is spam$/) }
    #     it { should have_sent_email.from('do-not-reply@example.com') }
    #     it { should have_sent_email.with_body(/is spam\./) }
    #     it { should have_sent_email.to('myself@me.com') }
    #     it { should have_sent_email.with_subject(/spam/).
    #                                 from('do-not-reply@example.com').
    #                                 with_body(/spam/).
    #                                 to('myself@me.com') }
    #   end
    module Matchers
    end
  end
end
