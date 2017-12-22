module Shoulda
  module Matchers
    module ActiveModel
      # The `validate_confirmation_of` matcher tests usage of the
      # `validates_confirmation_of` validation.
      #
      #     class User
      #       include ActiveModel::Model
      #       attr_accessor :email
      #
      #       validates_confirmation_of :email
      #     end
      #
      #     # RSpec
      #     RSpec.describe User, type: :model do
      #       it { should validate_confirmation_of(:email) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserTest < ActiveSupport::TestCase
      #       should validate_confirmation_of(:email)
      #     end
      #
      # #### Qualifiers
      #
      # ##### on
      #
      # Use `on` if your validation applies only under a certain context.
      #
      #     class User
      #       include ActiveModel::Model
      #       attr_accessor :password
      #
      #       validates_confirmation_of :password, on: :create
      #     end
      #
      #     # RSpec
      #     RSpec.describe User, type: :model do
      #       it { should validate_confirmation_of(:password).on(:create) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserTest < ActiveSupport::TestCase
      #       should validate_confirmation_of(:password).on(:create)
      #     end
      #
      # ##### with_message
      #
      # Use `with_message` if you are using a custom validation message.
      #
      #     class User
      #       include ActiveModel::Model
      #       attr_accessor :password
      #
      #       validates_confirmation_of :password,
      #         message: 'Please re-enter your password'
      #     end
      #
      #     # RSpec
      #     RSpec.describe User, type: :model do
      #       it do
      #         should validate_confirmation_of(:password).
      #           with_message('Please re-enter your password')
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserTest < ActiveSupport::TestCase
      #       should validate_confirmation_of(:password).
      #         with_message('Please re-enter your password')
      #     end
      #
      # @return [ValidateConfirmationOfMatcher]
      #
      def validate_confirmation_of(attr)
        ValidateConfirmationOfMatcher.new(attr)
      end

      # @private
      class ValidateConfirmationOfMatcher < ValidationMatcher
        include Helpers

        attr_reader :attribute, :confirmation_attribute

        def initialize(attribute)
          super
          @expected_message = :confirmation
          @confirmation_attribute = "#{attribute}_confirmation"
        end

        def simple_description
          "validate confirmation of :#{attribute}"
        end

        protected

        def add_submatchers
          add_matcher_disallowing_different_value
          add_matcher_allowing_same_value
          add_matcher_allowing_missing_confirmation
        end

        private

        attr_reader :expected_message, :confirmation_attribute

        def add_matcher_disallowing_different_value
          add_matcher_disallowing('different value') do |matcher|
            qualify_matcher(matcher, 'some value')
          end
        end

        def add_matcher_allowing_same_value
          add_matcher_allowing('same value') do |matcher|
            qualify_matcher(matcher, 'same value')
          end
        end

        def add_matcher_allowing_missing_confirmation
          add_matcher_allowing('any value') do |matcher|
            qualify_matcher(matcher, nil)
          end
        end

        def qualify_matcher(matcher, confirmation_attribute_value)
          matcher.values_to_preset = {
            confirmation_attribute => confirmation_attribute_value,
          }
          matcher.with_message(
            expected_message,
            against: confirmation_attribute,
            values: { attribute: model.human_attribute_name(attribute) },
          )
        end
      end
    end
  end
end
