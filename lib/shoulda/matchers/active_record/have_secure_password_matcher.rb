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
          "#{class_name} does not have secure password"
        end

        def negative_failure_message
          "#{class_name} does have secure password"
        end

        def description
          "make #{class_name} have secure password"
        end

        private

        def class_name
          @subject.class.name
        end

      end

    end
  end
end
