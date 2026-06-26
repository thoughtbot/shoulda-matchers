module Shoulda
  module Matchers
    module ActiveModel
      # The `have_secure_password` matcher tests usage of the
      # `has_secure_password` macro.
      #
      # #### Example
      #
      #     class User
      #       include ActiveModel::Model
      #       include ActiveModel::SecurePassword
      #       attr_accessor :password
      #       attr_accessor :reset_password
      #
      #       has_secure_password
      #       has_secure_password :reset_password
      #     end
      #
      #     # RSpec
      #     RSpec.describe User, type: :model do
      #       it { should have_secure_password }
      #       it { should have_secure_password(:reset_password) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserTest < ActiveSupport::TestCase
      #       should have_secure_password
      #       should have_secure_password(:reset_password)
      #     end
      #
      # #### Qualifiers
      #
      # ##### without_validations
      #
      # Use `without_validations` to assert that `has_secure_password` was
      # declared with `validations: false`, which opts out of the built-in
      # password presence, length, and confirmation validations.
      #
      #     class User
      #       include ActiveModel::Model
      #       include ActiveModel::SecurePassword
      #       attr_accessor :password
      #
      #       has_secure_password validations: false
      #     end
      #
      #     # RSpec
      #     RSpec.describe User, type: :model do
      #       it { should have_secure_password.without_validations }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserTest < ActiveSupport::TestCase
      #       should have_secure_password.without_validations
      #     end
      #
      # The built-in validations are detected through the confirmation validator
      # that `has_secure_password` registers, since the presence and length
      # checks are anonymous validators that cannot be inspected. A model that
      # opts out with `validations: false` and then defines its own
      # `validates_confirmation_of` will therefore be treated as having the
      # built-in validations.
      #
      # ##### with_reset_token
      #
      # Use `with_reset_token` to assert that `has_secure_password` generates a
      # password reset token (the `#{attribute}_reset_token` method along with
      # the `find_by_#{attribute}_reset_token` lookups). This is the default for
      # `has_secure_password` and is only supported on Rails 8.0 and later.
      #
      #     class User < ApplicationRecord
      #       has_secure_password
      #     end
      #
      #     # RSpec
      #     RSpec.describe User, type: :model do
      #       it { should have_secure_password.with_reset_token }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserTest < ActiveSupport::TestCase
      #       should have_secure_password.with_reset_token
      #     end
      #
      # Pass `expires_in` to also assert how long the reset token is valid for.
      # Configuring the expiry requires Rails 8.1 or later.
      #
      #     class User < ApplicationRecord
      #       has_secure_password reset_token: { expires_in: 1.hour }
      #     end
      #
      #     # RSpec
      #     RSpec.describe User, type: :model do
      #       it { should have_secure_password.with_reset_token(expires_in: 1.hour) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserTest < ActiveSupport::TestCase
      #       should have_secure_password.with_reset_token(expires_in: 1.hour)
      #     end
      #
      # ##### without_reset_token
      #
      # Use `without_reset_token` to assert that `has_secure_password` was
      # declared with `reset_token: false`, which opts out of generating the
      # password reset token. This is only supported on Rails 8.0 and later.
      #
      #     class User < ApplicationRecord
      #       has_secure_password reset_token: false
      #     end
      #
      #     # RSpec
      #     RSpec.describe User, type: :model do
      #       it { should have_secure_password.without_reset_token }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserTest < ActiveSupport::TestCase
      #       should have_secure_password.without_reset_token
      #     end
      #
      # @return [HaveSecurePasswordMatcher]
      #
      def have_secure_password(attr = :password)
        HaveSecurePasswordMatcher.new(attr)
      end

      # @private
      class HaveSecurePasswordMatcher
        attr_reader :failure_message

        CORRECT_PASSWORD = 'aBcDe12345'.freeze
        INCORRECT_PASSWORD = 'password'.freeze

        MESSAGES = {
          authenticated_incorrect_password: 'expected %{subject} to not'\
            ' authenticate an incorrect %{attribute}',
          did_not_authenticate_correct_password: 'expected %{subject} to'\
            ' authenticate the correct %{attribute}',
          method_not_found: 'expected %{subject} to respond to %{methods}',
          unexpected_validations: 'expected %{subject} to have a secure'\
            ' password without validations on %{attribute}, but the'\
            ' built-in validations were present',
          unexpected_reset_token: 'expected %{subject} to have a secure'\
            ' password without a reset token on %{attribute}, but a'\
            ' reset token was present',
          incorrect_reset_token_expiry: 'expected the %{attribute} reset'\
            ' token on %{subject} to expire in %{expected}, but it expires'\
            ' in %{actual}',
          should_not_have_secure_password: 'expected %{subject} to'\
            ' not %{description}!',
        }.freeze

        def initialize(attribute)
          @attribute = attribute.to_sym
          @expects_no_validations = false
          @reset_token = nil
        end

        def without_validations
          @expects_no_validations = true
          self
        end

        def with_reset_token(expires_in: nil)
          @reset_token = { expected: true, expires_in: expires_in }
          self
        end

        def without_reset_token
          @reset_token = { expected: false, expires_in: nil }
          self
        end

        def description
          text = "have a secure password, defined on #{@attribute} attribute"
          text += ' without validations' if @expects_no_validations
          text += ' with a reset token' if expects_reset_token?
          text += ' without a reset token' if expects_no_reset_token?
          text
        end

        def matches?(subject)
          @subject = subject

          assert_reset_token_qualifiers_supported!

          if failure = validate
            key, params = failure
            @failure_message =
              MESSAGES[key] % { subject: subject.class }.merge(params)
          end

          failure.nil?
        end

        def failure_message_when_negated
          MESSAGES[:should_not_have_secure_password] %
            { subject: @subject.class, description: }
        end

        protected

        attr_reader :subject

        def validate
          missing_methods = missing_expected_methods

          if missing_methods.present?
            [:method_not_found, { methods: missing_methods.to_sentence }]
          else
            subject.send("#{@attribute}=", CORRECT_PASSWORD)
            subject.send("#{@attribute}_confirmation=", CORRECT_PASSWORD)

            if not subject.send(authenticate_method, CORRECT_PASSWORD)
              [:did_not_authenticate_correct_password,
               { attribute: @attribute },]
            elsif subject.send(authenticate_method, INCORRECT_PASSWORD)
              [:authenticated_incorrect_password, { attribute: @attribute }]
            elsif @expects_no_validations && validations_present?
              [:unexpected_validations, { attribute: @attribute }]
            elsif expects_no_reset_token? && reset_token_present?
              [:unexpected_reset_token, { attribute: @attribute }]
            elsif expects_reset_token? && reset_token_expiry_mismatch?
              [:incorrect_reset_token_expiry,
               { attribute: @attribute,
                 expected: expected_reset_token_expires_in.inspect,
                 actual: actual_reset_token_expires_in.inspect, },]
            end
          end
        end

        private

        # `has_secure_password` (with the default `validations: true`) registers
        # a confirmation validator on the attribute alongside its other built-in
        # validations. They are all installed together, so the presence of that
        # validator is a reliable structural signal that validations are enabled
        # without having to run them, which is what `without_validations`
        # asserts against.
        def validations_present?
          return false unless subject.class.respond_to?(:validators_on)

          subject.class.validators_on(@attribute).any? do |validator|
            validator.is_a?(::ActiveModel::Validations::ConfirmationValidator)
          end
        end

        def missing_expected_methods
          expected_methods.reject { |m| subject.respond_to?(m) } +
            expected_class_methods.reject { |m| subject.class.respond_to?(m) }
        end

        def expected_methods
          methods = %I[
            #{authenticate_method}
            #{@attribute}=
            #{@attribute}_confirmation=
            #{@attribute}_digest
            #{@attribute}_digest=
          ]
          methods += reset_token_instance_methods if expects_reset_token?
          methods
        end

        def expected_class_methods
          expects_reset_token? ? reset_token_class_methods : []
        end

        # The `#{attribute}_reset_token_expires_in` reader only exists on Rails
        # 8.1+, so it is expected only when an expiry is asserted (which the
        # version gate already restricts to 8.1+). Including it then means a
        # missing reader fails with a clear `method_not_found` message rather
        # than a raw NoMethodError from #actual_reset_token_expires_in.
        def reset_token_instance_methods
          methods = [:"#{@attribute}_reset_token"]
          methods << :"#{@attribute}_reset_token_expires_in" if expiry_specified?
          methods
        end

        def reset_token_class_methods
          %I[
            find_by_#{@attribute}_reset_token
            find_by_#{@attribute}_reset_token!
          ]
        end

        def reset_token_present?
          subject.respond_to?(:"#{@attribute}_reset_token")
        end

        def reset_token_expiry_mismatch?
          return false unless expiry_specified?

          actual_reset_token_expires_in != expected_reset_token_expires_in
        end

        def actual_reset_token_expires_in
          subject.public_send(:"#{@attribute}_reset_token_expires_in")
        end

        def assert_reset_token_qualifiers_supported!
          if reset_token_qualified? && !RailsShim.active_model_gte_8_0?
            raise reset_token_not_supported_error('8.0')
          elsif expiry_specified? && !RailsShim.active_model_gte_8_1?
            raise reset_token_not_supported_error('8.1')
          end
        end

        def reset_token_not_supported_error(required_version)
          ResetTokenNotSupportedError.create(
            model: @subject.class,
            qualifier: reset_token_qualifier_name,
            required_version: required_version,
          )
        end

        def reset_token_qualifier_name
          if expiry_specified?
            'with_reset_token(expires_in:)'
          elsif expects_reset_token?
            'with_reset_token'
          else
            'without_reset_token'
          end
        end

        def reset_token_qualified?
          !@reset_token.nil?
        end

        def expects_reset_token?
          @reset_token && @reset_token[:expected]
        end

        def expects_no_reset_token?
          @reset_token && !@reset_token[:expected]
        end

        def expiry_specified?
          !expected_reset_token_expires_in.nil?
        end

        def expected_reset_token_expires_in
          @reset_token && @reset_token[:expires_in]
        end

        def authenticate_method
          if @attribute == :password
            :authenticate
          else
            "authenticate_#{@attribute}".to_sym
          end
        end

        # @private
        class ResetTokenNotSupportedError < Shoulda::Matchers::Error
          attr_accessor :model, :qualifier, :required_version

          def message
            Shoulda::Matchers.word_wrap <<-MESSAGE
The `#{qualifier}` qualifier requires Rails #{required_version} or later, but
#{model.name} is running an earlier version.
            MESSAGE
          end
        end
      end
    end
  end
end
