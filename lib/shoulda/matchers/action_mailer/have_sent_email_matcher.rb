require 'active_support/deprecation'

module Shoulda # :nodoc:
  module Matchers
    module ActionMailer # :nodoc:

      # The right email is sent.
      #
      #   it { should have_sent_email.with_subject(/is spam$/) }
      #   it { should have_sent_email.from('do-not-reply@example.com') }
      #   it { should have_sent_email.with_body(/is spam\./) }
      #   it { should have_sent_email.to('myself@me.com') }
      #   it { should have_sent_email.with_part('text/html', /HTML spam/) }
      #   it { should have_sent_email.with_subject(/spam/).
      #                               from('do-not-reply@example.com').
      #                               reply_to('reply-to-me@example.com').
      #                               with_body(/spam/).
      #                               to('myself@me.com') }
      #
      # Use values of instance variables
      #   it {should have_sent_email.to {@user.email} }
      def have_sent_email
        HaveSentEmailMatcher.new(self)
      end

      class HaveSentEmailMatcher # :nodoc:

        def initialize(context)
          ActiveSupport::Deprecation.warn 'The have_sent_email matcher is deprecated and will be removed in 2.0'
          @context = context
        end

        def in_context(context)
          @context = context
          self
        end

        def with_subject(email_subject = nil, &block)
          @email_subject = email_subject
          @email_subject_block = block
          self
        end

        def from(sender = nil, &block)
          @sender = sender
          @sender_block = block
          self
        end

        def reply_to(reply_to = nil, &block)
          @reply_to = reply_to
          @reply_to_block = block
          self
        end

        def with_body(body = nil, &block)
          @body = body
          @body_block = block
          self
        end

        def with_part(content_type, body = nil, &block)
          @parts ||= []
          @parts << [/#{Regexp.escape(content_type)}/, body, content_type]
          @parts_blocks ||= []
          @parts_blocks << block
          self
        end

        def to(recipient = nil, &block)
          @recipient = recipient
          @recipient_block = block
          self
        end

        def cc(recipient = nil, &block)
          @cc = recipient
          @cc_block = block
          self
        end

        def with_cc(recipients = nil, &block)
          @cc_recipients = recipients
          @cc_recipients_block = block
          self
        end

        def bcc(recipient = nil, &block)
          @bcc = recipient
          @bcc_block = block
          self
        end

        def with_bcc(recipients = nil, &block)
          @bcc_recipients = recipients
          @bcc_recipients_block = block
          self
        end

        def multipart(flag = true)
          @multipart = !!flag
          self
        end

        def matches?(subject)
          normalize_blocks
          ::ActionMailer::Base.deliveries.any? do |mail|
            mail_matches?(mail)
          end
        end

        def failure_message_for_should
          "Expected #{expectation}"
        end

        def failure_message_for_should_not
          "Did not expect #{expectation}"
        end

        def description
          description  = 'send an email'
          description << " with a subject of #{@email_subject.inspect}" if @email_subject
          description << " containing #{@body.inspect}" if @body
          if @parts
            @parts.each do |_, body, content_type|
              description << " having a #{content_type} part containing #{body.inspect}"
            end
          end
          description << " from #{@sender.inspect}" if @sender
          description << " reply to #{@reply_to.inspect}" if @reply_to
          description << " to #{@recipient.inspect}" if @recipient
          description << " cc #{@cc.inspect}" if @cc
          description << " with cc #{@cc_recipients.inspect}" if @cc_recipients
          description << " bcc #{@bcc.inspect}" if @bcc
          description << " with bcc #{@bcc_recipients.inspect}" if @bcc_recipients
          description
        end

        private

        def expectation
          expectation = 'sent email'
          expectation << " with subject #{@email_subject.inspect}" if @subject_failed
          expectation << " with body #{@body.inspect}" if @body_failed
          @parts.each do |_, body, content_type|
            expectation << " with a #{content_type} part containing #{body}"
          end if @parts && @parts_failed
          expectation << " from #{@sender.inspect}" if @sender_failed
          expectation << " reply to #{@reply_to.inspect}" if @reply_to_failed
          expectation << " to #{@recipient.inspect}" if @recipient_failed
          expectation << " cc #{@cc.inspect}" if @cc_failed
          expectation << " with cc #{@cc_recipients.inspect}" if @cc_recipients_failed
          expectation << " bcc #{@bcc.inspect}" if @bcc_failed
          expectation << " with bcc #{@bcc_recipients.inspect}" if @bcc_recipients_failed
          expectation << " #{'not ' if !@multipart}being multipart" if @multipart_failed
          expectation << "\nDeliveries:\n#{inspect_deliveries}"
        end

        def inspect_deliveries
          ::ActionMailer::Base.deliveries.map do |delivery|
            "#{delivery.subject.inspect} to #{delivery.to.inspect}"
          end.join("\n")
        end

        def mail_matches?(mail)
          @subject_failed = !regexp_or_string_match(mail.subject, @email_subject) if @email_subject
          @parts_failed = !parts_match(mail, @parts) if @parts
          @body_failed = !body_match(mail, @body) if @body
          @sender_failed = !regexp_or_string_match_in_array(mail.from, @sender) if @sender
          @reply_to_failed = !regexp_or_string_match_in_array(mail.reply_to, @reply_to) if @reply_to
          @recipient_failed = !regexp_or_string_match_in_array(mail.to, @recipient) if @recipient
          @cc_failed = !regexp_or_string_match_in_array(mail.cc, @cc) if @cc
          @cc_recipients_failed = !match_array_in_array(mail.cc, @cc_recipients) if @cc_recipients
          @bcc_failed = !regexp_or_string_match_in_array(mail.bcc, @bcc) if @bcc
          @bcc_recipients_failed = !match_array_in_array(mail.bcc, @bcc_recipients) if @bcc_recipients
          @multipart_failed = (mail.multipart? != @multipart) if defined?(@multipart)

          ! anything_failed?
        end

        def anything_failed?
          @subject_failed || @body_failed || @sender_failed || @reply_to_failed ||
            @recipient_failed || @cc_failed || @cc_recipients_failed || @bcc_failed ||
            @bcc_recipients_failed || @parts_failed || @multipart_failed
        end

        def normalize_blocks
          @email_subject = @context.instance_eval(&@email_subject_block) if @email_subject_block
          @sender = @context.instance_eval(&@sender_block) if @sender_block
          @reply_to = @context.instance_eval(&@reply_to_block) if @reply_to_block
          @body = @context.instance_eval(&@body_block) if @body_block
          @recipient = @context.instance_eval(&@recipient_block) if @recipient_block
          @cc = @context.instance_eval(&@cc_block) if @cc_block
          @cc_recipients = @context.instance_eval(&@cc_recipients_block) if @cc_recipients_block
          @bcc = @context.instance_eval(&@bcc_block) if @bcc_block
          @bcc_recipients = @context.instance_eval(&@bcc_recipients_block) if @bcc_recipients_block

          if @parts
            @parts.each_with_index do |part, i|
              part[1] = @context.instance_eval(&@parts_blocks[i]) if @parts_blocks[i]
            end
          end
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

          target_array.each_cons(match_array.size).include?(match_array)
        end

        def body_match(mail, a_regexp_or_string)
          # Mail objects instantiated by ActionMailer3 return a blank
          # body if the e-mail is multipart. TMail concatenates the
          # String representation of each part instead.
          if mail.body.blank? && mail.multipart?
            part_match(mail, /^text\//, a_regexp_or_string)
          else
            regexp_or_string_match(mail.body, a_regexp_or_string)
          end
        end

        def parts_match(mail, parts)
          return false if mail.parts.empty?

          parts.all? do |content_type, match, _|
            part_match(mail, content_type, match)
          end
        end

        def part_match(mail, content_type, a_regexp_or_string)
          matching = mail.parts.select {|p| p.content_type =~ content_type}
          return false if matching.empty?

          matching.all? do |part|
            regexp_or_string_match(part.body, a_regexp_or_string)
          end
        end
      end
    end
  end
end
