module Shoulda
  module Matchers
    module ActiveModel
      # The `validate_presence_of` matcher tests usage of the
      # `validates_presence_of` validation.
      #
      #     class Robot
      #       include ActiveModel::Model
      #       attr_accessor :arms
      #
      #       validates_presence_of :arms
      #     end
      #
      #     # RSpec
      #     RSpec.describe Robot, type: :model do
      #       it { should validate_presence_of(:arms) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class RobotTest < ActiveSupport::TestCase
      #       should validate_presence_of(:arms)
      #     end
      #
      # #### Caveats
      #
      # Under Rails 4 and greater, if your model `has_secure_password` and you
      # are validating presence of the password using a record whose password
      # has already been set prior to calling the matcher, you will be
      # instructed to use a record whose password is empty instead.
      #
      # For example, given this scenario:
      #
      #     class User < ActiveRecord::Base
      #       has_secure_password validations: false
      #
      #       validates_presence_of :password
      #     end
      #
      #     RSpec.describe User, type: :model do
      #       subject { User.new(password: '123456') }
      #
      #       it { should validate_presence_of(:password) }
      #     end
      #
      # the above test will raise an error like this:
      #
      #     The validation failed because your User model declares
      #     `has_secure_password`, and `validate_presence_of` was called on a
      #     user which has `password` already set to a value. Please use a user
      #     with an empty `password` instead.
      #
      # This happens because `has_secure_password` itself overrides your model
      # so that it is impossible to set `password` to nil. This means that it is
      # impossible to test that setting `password` to nil places your model in
      # an invalid state (which in turn means that the validation itself is
      # unnecessary).
      #
      # #### Qualifiers
      #
      # ##### on
      #
      # Use `on` if your validation applies only under a certain context.
      #
      #     class Robot
      #       include ActiveModel::Model
      #       attr_accessor :arms
      #
      #       validates_presence_of :arms, on: :create
      #     end
      #
      #     # RSpec
      #     RSpec.describe Robot, type: :model do
      #       it { should validate_presence_of(:arms).on(:create) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class RobotTest < ActiveSupport::TestCase
      #       should validate_presence_of(:arms).on(:create)
      #     end
      #
      # ##### with_message
      #
      # Use `with_message` if you are using a custom validation message.
      #
      #     class Robot
      #       include ActiveModel::Model
      #       attr_accessor :legs
      #
      #       validates_presence_of :legs, message: 'Robot has no legs'
      #     end
      #
      #     # RSpec
      #     RSpec.describe Robot, type: :model do
      #       it do
      #         should validate_presence_of(:legs).
      #           with_message('Robot has no legs')
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class RobotTest < ActiveSupport::TestCase
      #       should validate_presence_of(:legs).
      #         with_message('Robot has no legs')
      #     end
      #
      # @return [ValidatePresenceOfMatcher]
      #
      def validate_presence_of(attr)
        ValidatePresenceOfMatcher.new(attr)
      end

      # @private
      class ValidatePresenceOfMatcher < ValidationMatcher
        def initialize(attribute)
          super
          @expected_message = :blank
        end

        def matches?(subject)
          super(subject)

          if secure_password_being_validated?
            ignore_interference_by_writer.default_to(when: :blank?)
            disallows_and_double_checks_value_of!(blank_value, @expected_message)
          else
            disallows_original_or_typecast_value?(blank_value, @expected_message)
          end
        end

        def simple_description
          "validate that :#{@attribute} cannot be empty/falsy"
        end

        private

        def secure_password_being_validated?
          defined?(::ActiveModel::SecurePassword) &&
            @subject.class.ancestors.include?(::ActiveModel::SecurePassword::InstanceMethodsOnActivation) &&
            @attribute == :password
        end

        def disallows_and_double_checks_value_of!(value, message)
          disallows_value_of(value, message)
        rescue ActiveModel::AllowValueMatcher::AttributeChangedValueError
          raise ActiveModel::CouldNotSetPasswordError.create(@subject.class)
        end

        def disallows_original_or_typecast_value?(value, message)
          disallows_value_of(blank_value, @expected_message)
        end

        def blank_value
          if collection?
            []
          else
            nil
          end
        end

        def collection?
          if reflection
            [:has_many, :has_and_belongs_to_many].include?(reflection.macro)
          else
            false
          end
        end

        def reflection
          @subject.class.respond_to?(:reflect_on_association) &&
            @subject.class.reflect_on_association(@attribute)
        end
      end
    end
  end
end
