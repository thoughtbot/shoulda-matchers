module Shoulda
  module Matchers
    module ActiveRecord
      # The `have_secure_token` matcher tests usage of the
      # `has_secure_token` macro.
      #
      # #### Example
      #
      #     class User < ActiveRecord::Base
      #       has_secure_token
      #       has_secure_token(:public_id)
      #     end
      #
      #     # RSpec
      #     describe User do
      #       it { should have_secure_token }
      #       it { should have_secure_token(:public_id) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserTest < ActiveSupport::TestCase
      #       should have_secure_token
      #       should have_secure_token(:public_id)
      #     end
      #
      # @return [HaveSecureTokenMatcher]
      #
      def have_secure_token(attr = :token)
        HaveSecureTokenMatcher.new(attr)
      end

      # @private
      class HaveSecureTokenMatcher # :nodoc:
        def initialize(attr)
          @attr = attr
        end

        def description
          "have a secure token #{attr}"
        end

        def matches?(subject)
          @subject = subject
          validate
        end

        def failure_message
          "Expected #{expectation}"
        end

        def failure_message_when_negated
          "Did not expect #{expectation}"
        end

        protected

        attr_reader :subject, :attr

        def expectation
          "#{subject.class.name} to have a has_secure_token(:#{attr})"
        end

        def validate
          result = validate_attribute_have_regenerate_method? &&
                   validate_class_have_generate_secure_token_method?

          if result && subject.new_record? && subject.send(attr).blank?
            result = subject.save(validate: false) &&
                     subject.send("#{attr}?")
          end

          result
        end

        def validate_attribute_have_regenerate_method?
          subject.respond_to?(:"regenerate_#{attr}")
        end

        def validate_class_have_generate_secure_token_method?
          subject.class.respond_to?(:generate_unique_secure_token)
        end
      end
    end
  end
end
