module Shoulda
  module Matchers
    module ActiveModel
      # The `validate_acceptance_of` matcher tests usage of the
      # `validates_acceptance_of` validation.
      #
      #     class Registration
      #       include ActiveModel::Model
      #       attr_accessor :eula
      #
      #       validates_acceptance_of :eula
      #     end
      #
      #     # RSpec
      #     describe Registration do
      #       it { should validate_acceptance_of(:eula) }
      #     end
      #
      #     # Test::Unit
      #     class RegistrationTest < ActiveSupport::TestCase
      #       should validate_acceptance_of(:eula)
      #     end
      #
      # #### Qualifiers
      #
      # ##### with_message
      #
      # Use `with_message` if you are using a custom validation message.
      #
      #     class Registration
      #       include ActiveModel::Model
      #       attr_accessor :terms_of_service
      #
      #       validates_acceptance_of :terms_of_service,
      #         message: 'You must accept the terms of service'
      #     end
      #
      #     # RSpec
      #     describe Registration do
      #       it do
      #         should validate_acceptance_of(:terms_of_service).
      #           with_message('You must accept the terms of service')
      #       end
      #     end
      #
      #     # Test::Unit
      #     class RegistrationTest < ActiveSupport::TestCase
      #       should validate_acceptance_of(:terms_of_service).
      #         with_message('You must accept the terms of service')
      #     end
      #
      # @return [ValidateAcceptanceOfMatcher]
      #
      def validate_acceptance_of(attr)
        ValidateAcceptanceOfMatcher.new(attr)
      end

      # @private
      class ValidateAcceptanceOfMatcher < ValidationMatcher
        def with_message(message)
          if message
            @expected_message = message
          end
          self
        end

        def matches?(subject)
          super(subject)
          @expected_message ||= :accepted
          disallows_value_of(false, @expected_message)
        end

        def description
          "require #{@attribute} to be accepted"
        end
      end
    end
  end
end
