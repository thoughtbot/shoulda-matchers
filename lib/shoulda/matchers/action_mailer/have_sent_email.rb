module Shoulda # :nodoc:
  module Matchers
    module ActionMailer # :nodoc:

      # The right email is sent.
      #
      #   it { should have_sent_email.with_subject(/is spam$/) }
      #   it { should have_sent_email.from('do-not-reply@example.com') }
      #   it { should have_sent_email.with_body(/is spam\./) }
      #   it { should have_sent_email.to('myself@me.com') }
      #   it { should have_sent_email.with_subject(/spam/).
      #                               from('do-not-reply@example.com').
      #                               with_body(/spam/).
      #                               to('myself@me.com') }
      def have_sent_email
        HaveSentEmailMatcher.new
      end

      class HaveSentEmailMatcher # :nodoc:

        def initialize
        end

        def with_subject(email_subject)
          @email_subject = email_subject
          self
        end

        def from(sender)
          @sender = sender
          self
        end

        def with_body(body)
          @body = body
          self
        end

        def to(recipient)
          @recipient = recipient
          self
        end
        
        def cc(recipient)
          @cc = recipient
          self
        end
        
        def with_cc(recipients)
          @cc_recipients = recipients
          self
        end
        
        def bcc(recipient)
          @bcc = recipient
          self
        end
        
        def with_bcc(recipients)
          @bcc_recipients = recipients
          self
        end

        def matches?(subject)
          ::ActionMailer::Base.deliveries.each do |mail|
            @subject_failed = !regexp_or_string_match(mail.subject, @email_subject) if @email_subject
            @body_failed = !regexp_or_string_match(mail.body, @body) if @body
            @sender_failed = !regexp_or_string_match_in_array(mail.from, @sender) if @sender
            @recipient_failed = !regexp_or_string_match_in_array(mail.to, @recipient) if @recipient
            @cc_failed = !regexp_or_string_match_in_array(mail.cc, @cc) if @cc
            @cc_recipients_failed = !match_array_in_array(mail.cc, @cc_recipients) if @cc_recipients
            @bcc_failed = !regexp_or_string_match_in_array(mail.bcc, @bcc) if @bcc
            @bcc_recipients_failed = !match_array_in_array(mail.bcc, @bcc_recipients) if @bcc_recipients
            return true unless anything_failed?
          end

          false
        end

        def failure_message
          "Expected #{expectation}"
        end

        def negative_failure_message
          "Did not expect #{expectation}"
        end

        def description
          description  = "send an email"
          description << " with a subject of #{@email_subject.inspect}" if @email_subject
          description << " containing #{@body.inspect}" if @body
          description << " from #{@sender.inspect}" if @sender
          description << " to #{@recipient.inspect}" if @recipient
          description << " cc #{@cc.inspect}" if @cc
          description << " with cc #{@cc_recipients.inspect}" if @cc_recipients
          description << " bcc #{@bcc.inspect}" if @bcc
          description << " with bcc #{@bcc_recipients.inspect}" if @bcc_recipients
          description
        end

        private

        def expectation
          expectation = "sent email"
          expectation << " with subject #{@email_subject.inspect}" if @subject_failed
          expectation << " with body #{@body.inspect}" if @body_failed
          expectation << " from #{@sender.inspect}" if @sender_failed
          expectation << " to #{@recipient.inspect}" if @recipient_failed
          expectation << " cc #{@cc.inspect}" if @cc_failed
          expectation << " with cc #{@cc_recipients.inspect}" if @cc_recipients_failed
          expectation << " bcc #{@bcc.inspect}" if @bcc_failed
          expectation << " with bcc #{@bcc_recipients.inspect}" if @bcc_recipients_failed
          expectation << "\nDeliveries:\n#{inspect_deliveries}"
        end

        def inspect_deliveries
          ::ActionMailer::Base.deliveries.map do |delivery|
            "#{delivery.subject.inspect} to #{delivery.to.inspect}"
          end.join("\n")
        end

        def anything_failed?
          @subject_failed || @body_failed || @sender_failed || @recipient_failed || @cc_failed || @cc_recipients_failed || @bcc_failed || @bcc_recipients_failed
        end

        def regexp_or_string_match(a_string, a_regexp_or_string)
          case a_regexp_or_string
          when Regexp
            a_string =~ a_regexp_or_string
          when String
            a_string == a_regexp_or_string
          end
        end

        def regexp_or_string_match_in_array(an_array, a_regexp_or_string)
          case a_regexp_or_string
          when Regexp
            an_array.any? { |string| string =~ a_regexp_or_string }
          when String
            an_array.include?(a_regexp_or_string)
          end
        end
        
        def match_array_in_array(target_array, match_array)
          target_array.sort!
          match_array.sort!
          
          target_array.each_cons(match_array.size).include? match_array
        end
      end
    end
  end

end
