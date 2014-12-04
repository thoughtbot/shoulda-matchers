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
      #     describe Robot do
      #       it { should validate_presence_of(:arms) }
      #     end
      #
      #     # Test::Unit
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
      #     describe User do
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
      #     describe Robot do
      #       it { should validate_presence_of(:arms).on(:create) }
      #     end
      #
      #     # Test::Unit
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
      #     describe Robot do
      #       it do
      #         should validate_presence_of(:legs).
      #           with_message('Robot has no legs')
      #       end
      #     end
      #
      #     # Test::Unit
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
        def with_message(message)
          @expected_message = message if message
          self
        end

        def matches?(subject)
          super(subject)
          @expected_message ||= :blank

          if secure_password_being_validated?
            disallows_and_double_checks_value_of!(blank_value, @expected_message)
          else
            disallows_value_of(blank_value, @expected_message)
          end
        end

        def description
          "require #{@attribute} to be set"
        end

        private

        def secure_password_being_validated?
          defined?(::ActiveModel::SecurePassword) &&
            @subject.class.ancestors.include?(::ActiveModel::SecurePassword::InstanceMethodsOnActivation) &&
            @attribute == :password
        end

        def disallows_and_double_checks_value_of!(value, message)
          error_class = Shoulda::Matchers::ActiveModel::CouldNotSetPasswordError

          disallows_value_of(value, message) do |matcher|
            matcher._after_setting_value do
              actual_value = @subject.__send__(@attribute)

              if !actual_value.nil?
                raise error_class.create(@subject.class)
              end
            end
          end
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
