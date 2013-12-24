module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:

      # Ensures that the model exhibits behavior added by has_secure_password.
      #
      # Example:
      #   it { should have_secure_password }
      def have_secure_password
        HaveSecurePasswordMatcher.new
      end

      class HaveSecurePasswordMatcher # :nodoc:
        attr_reader :failure_message

        alias failure_message_for_should failure_message

        CORRECT_PASSWORD = "aBcDe12345"
        INCORRECT_PASSWORD = "password"

        EXPECTED_METHODS = [
          :authenticate,
          :password=,
          :password_confirmation=,
          :password_digest,
          :password_digest=,
        ]

        MESSAGES = {
          authenticated_incorrect_password: "expected %{subject} to not authenticate an incorrect password",
          did_not_authenticate_correct_password: "expected %{subject} to authenticate the correct password",
          method_not_found: "expected %{subject} to respond to %{methods}"
        }

        def description
          "have a secure password"
        end

        def matches?(subject)
          @subject = subject

          if failure = validate
            key, params = failure
            @failure_message = MESSAGES[key] % { subject: subject.class }.merge(params)
          end

          failure.nil?
        end

        private

        attr_reader :subject

        def validate
          missing_methods = EXPECTED_METHODS.select {|m| !subject.respond_to?(m) }

          if missing_methods.present?
            [:method_not_found, { methods: missing_methods.to_sentence }]
          else
            subject.password = CORRECT_PASSWORD
            subject.password_confirmation = CORRECT_PASSWORD

            if not subject.authenticate(CORRECT_PASSWORD)
              [:did_not_authenticate_correct_password, {}]
            elsif subject.authenticate(INCORRECT_PASSWORD)
              [:authenticated_incorrect_password, {}]
            end
          end
        end
      end
    end
  end
end
