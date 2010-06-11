module Shoulda # :nodoc:
  module ActionMailer # :nodoc:
    module Matchers

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
          msg = "expected a sent email"
          msg += " with subject #{@email_subject.inspect}" if @subject_failed
          msg += " with body #{@body.inspect}" if @body_failed
          msg += " from #{@sender.inspect}" if @sender_failed
          msg += " to #{@recipient.inspect}" if @recipient_failed
          if anything_failed?
            msg += " but got"
            msg += " the subject #{@mail.subject.inspect}" if @subject_failed
            msg += " the body #{@mail.body.inspect}" if @body_failed
            msg += " from #{@mail.from.inspect}" if @sender_failed
            msg += " to #{@mail.to.inspect}" if @recipient_failed
          end
          msg
        end

        def negative_failure_message
          msg = "expected no sent email"
          msg += " with subject #{@email_subject.inspect}" if @subject_failed
          msg += " with body #{@body.inspect}" if @body_failed
          msg += " from #{@sender.inspect}" if @sender_failed
          msg += " to #{@recipient.inspect}" if @recipient_failed
          if anything_failed?
            msg += " but got"
            msg += " the subject #{@mail.subject.inspect}" if @subject_failed
            msg += " the body #{@mail.body.inspect}" if @body_failed
            msg += " from #{@mail.from.inspect}" if @sender_failed
            msg += " to #{@mail.to.inspect}" if @recipient_failed
          end
          msg
        end

        def description
          "send an email"
        end

        private

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

