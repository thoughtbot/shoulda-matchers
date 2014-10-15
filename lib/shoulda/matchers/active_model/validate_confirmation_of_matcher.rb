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
      #     # Test::Unit
      #     class UserTest < ActiveSupport::TestCase
      #       should validate_confirmation_of(:email)
      #     end
      #
      # #### Qualifiers
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
      #     # Test::Unit
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
          super(attribute)
          @confirmation_attribute = "#{attribute}_confirmation"
        end

        def with_message(message)
          @message = message if message
          self
        end

        def description
          "require #{@confirmation_attribute} to match #{@attribute}"
        end

        def matches?(subject)
          super(subject)
          @message ||= :confirmation

          disallows_different_value &&
            allows_same_value &&
            allows_missing_confirmation
        end

        private

        def disallows_different_value
          set_confirmation('some value')
          disallows_value_of('different value') do |matcher|
            qualify_matcher(matcher)
          end
        end

        def allows_same_value
          set_confirmation('same value')
          allows_value_of('same value') do |matcher|
            qualify_matcher(matcher)
          end
        end

        def allows_missing_confirmation
          set_confirmation(nil)
          allows_value_of('any value') do |matcher|
            qualify_matcher(matcher)
          end
        end

        def qualify_matcher(matcher)
          matcher.with_message(@message,
            against: error_attribute,
            values: { attribute: attribute }
          )
        end

        def set_confirmation(val)
          setter = :"#{@confirmation_attribute}="
          if @subject.respond_to?(setter)
            @subject.__send__(setter, val)
          end
        end

        def error_attribute
          RailsShim.validates_confirmation_of_error_attribute(self)
        end
      end
    end
  end
end
