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
      #     describe User do
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
      #     describe User do
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
      #     describe User do
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
      def validate_confirmation_of(attr, data_type = :string)
        ValidateConfirmationOfMatcher.new(attr, data_type)
      end

      # @private
      class ValidateConfirmationOfMatcher < ValidationMatcher
        include Helpers

        attr_reader :attribute, :confirmation_attribute

        def initialize(attribute, data_type = :string)
          super(attribute)
          @expected_message = :confirmation
          @confirmation_attribute = "#{attribute}_confirmation"
          @data_type = data_type
        end

        def simple_description
          "validate that #{@confirmation_attribute} matches #{@attribute}"
        end

        def matches?(subject)
          super(subject)
          if @data_type == :integer
            disallows_different_integer_value &&
              allows_same_integer_value &&
              allows_missing_confirmation_for_integers
          else
            disallows_different_value &&
              allows_same_value &&
              allows_missing_confirmation
          end
        end

        private

        def disallows_different_value
          set_confirmation('some value')

          disallows_value_of('different value') do |matcher|
            qualify_matcher(matcher)
          end
        end

        def disallows_different_integer_value
          set_confirmation(1)

          disallows_value_of(0) do |matcher|
            qualify_matcher(matcher)
          end
        end

        def allows_same_value
          set_confirmation('same value')

          allows_value_of('same value') do |matcher|
            qualify_matcher(matcher)
          end
        end

        def allows_same_integer_value
          set_confirmation(1)

          allows_value_of(1) do |matcher|
            qualify_matcher(matcher)
          end
        end

        def allows_missing_confirmation
          set_confirmation(nil)

          allows_value_of('any value') do |matcher|
            qualify_matcher(matcher)
          end
        end

        def allows_missing_confirmation_for_integers
          set_confirmation(nil)

          allows_value_of(1) do |matcher|
            qualify_matcher(matcher)
          end
        end

        def qualify_matcher(matcher)
          matcher.with_message(
            @expected_message,
            against: confirmation_attribute,
            values: { attribute: attribute }
          )
        end

        def set_confirmation(val)
          setter = :"#{@confirmation_attribute}="

          if @subject.respond_to?(setter)
            @subject.__send__(setter, val)
          end
        end
      end
    end
  end
end
