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
      #     # Minitest (Shoulda)
      #     class RegistrationTest < ActiveSupport::TestCase
      #       should validate_acceptance_of(:eula)
      #     end
      #
      # #### Qualifiers
      #
      # ##### on
      #
      # Use `on` if your validation applies only under a certain context.
      #
      #     class Registration
      #       include ActiveModel::Model
      #       attr_accessor :terms_of_service
      #
      #       validates_acceptance_of :terms_of_service, on: :create
      #     end
      #
      #     # RSpec
      #     describe Registration do
      #       it do
      #         should validate_acceptance_of(:terms_of_service).
      #           on(:create)
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class RegistrationTest < ActiveSupport::TestCase
      #       should validate_acceptance_of(:terms_of_service).on(:create)
      #     end
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
      #     # Minitest (Shoulda)
      #     class RegistrationTest < ActiveSupport::TestCase
      #       should validate_acceptance_of(:terms_of_service).
      #         with_message('You must accept the terms of service')
      #     end
      #
      # ##### ignoring_interference_by_writer
      #
      # Use `ignoring_interference_by_writer` when the attribute you're testing
      # changes incoming values. This qualifier will instruct the matcher to
      # suppress raising an AttributeValueChangedError, as long as changing the
      # doesn't also change the outcome of the test and cause it to fail. See
      # the documentation for `allow_value` for more information on this.
      #
      #     class Registration
      #       include ActiveModel::Model
      #       attr_accessor :terms_of_service
      #
      #       validates_acceptance_of :terms_of_service
      #
      #       def terms_of_service=(value)
      #         @terms_of_service = value || 'something else'
      #       end
      #     end
      #
      #     # RSpec
      #     describe Registration do
      #       it do
      #         should validate_acceptance_of(:terms_of_service).
      #           ignoring_interference_by_writer
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class RegistrationTest < ActiveSupport::TestCase
      #       should validate_acceptance_of(:terms_of_service).
      #         ignoring_interference_by_writer
      #     end
      #
      # @return [ValidateAcceptanceOfMatcher]
      #
      def validate_acceptance_of(attr)
        ValidateAcceptanceOfMatcher.new(attr)
      end

      # @private
      class ValidateAcceptanceOfMatcher < ValidationMatcher
        def initialize(attribute)
          super
          @expected_message = :accepted
        end

        def matches?(subject)
          super(subject)
          disallows_value_of(false, @expected_message)
        end

        def simple_description
          %(validate that :#{@attribute} has been set to "1")
        end
      end
    end
  end
end
