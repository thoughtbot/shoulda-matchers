module Shoulda # :nodoc:
  module ActionMailer # :nodoc:
    module Matchers

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

        def matches?(subject)
          ::ActionMailer::Base.deliveries.each do |mail|
            @subject_failed = !regexp_or_string_match(mail.subject, @email_subject) if @email_subject
            @body_failed = !regexp_or_string_match(mail.body, @body) if @body
            @sender_failed = !regexp_or_string_match_in_array(mail.from, @sender) if @sender
            @recipient_failed = !regexp_or_string_match_in_array(mail.to, @recipient) if @recipient
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
          "send an email"
        end

        private

        def expectation
          expectation = "sent email"
          expectation << " with subject #{@email_subject.inspect}" if @subject_failed
          expectation << " with body #{@body.inspect}" if @body_failed
          expectation << " from #{@sender.inspect}" if @sender_failed
          expectation << " to #{@recipient.inspect}" if @recipient_failed
          expectation << "\nDeliveries:\n#{inspect_deliveries}"
        end

        def inspect_deliveries
          ::ActionMailer::Base.deliveries.map do |delivery|
            "#{delivery.subject.inspect} to #{delivery.to.inspect}"
          end.join("\n")
        end

        def anything_failed?
          @subject_failed || @body_failed || @sender_failed || @recipient_failed
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
            an_array.detect{|e| e =~ a_regexp_or_string}.any?
          when String
            an_array.include?(a_regexp_or_string)
          end
        end
      end
    end
  end
end

