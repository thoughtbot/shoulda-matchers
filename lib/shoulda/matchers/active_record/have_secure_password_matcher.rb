module Shoulda # :nodoc:
  module Matchers
    module ActiveRecord # :nodoc:

      # Ensures that the model uses has_secure_password
      #
      #   it { should have_secure_password(:password) }
      #
      def have_secure_password
        HaveSecurePasswordMatcher.new
      end

      class HaveSecurePasswordMatcher # :nodoc:
        def matches?(subject)
          @subject = subject
          @subject.class.included_modules.collect(&:to_s).include?('ActiveModel::SecurePassword::InstanceMethodsOnActivation')
        end

        def failure_message
          'does not have secure password'
        end

        def negative_failure_message
          'does have secure password'
        end

        def description
          'have secure password'
        end
      end

    end
  end
end
