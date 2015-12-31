module Shoulda
  module Matchers
    module ActiveModel
      # The `validate_length_of` matcher tests usage of the
      # `validates_length_of` matcher. Note that this matcher is intended to be
      # used against string columns and not integer columns.
      #
      # #### Qualifiers
      #
      # Use `on` if your validation applies only under a certain context.
      #
      #     class User
      #       include ActiveModel::Model
      #       attr_accessor :password
      #
      #       validates_length_of :password, minimum: 10, on: :create
      #     end
      #
      #     # RSpec
      #     describe User do
      #       it do
      #         should validate_length_of(:password).
      #           is_at_least(10).
      #           on(:create)
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserTest < ActiveSupport::TestCase
      #       should validate_length_of(:password).
      #         is_at_least(10).
      #         on(:create)
      #     end
      #
      # ##### is_at_least
      #
      # Use `is_at_least` to test usage of the `:minimum` option. This asserts
      # that the attribute can take a string which is equal to or longer than
      # the given length and cannot take a string which is shorter.
      #
      #     class User
      #       include ActiveModel::Model
      #       attr_accessor :bio
      #
      #       validates_length_of :bio, minimum: 15
      #     end
      #
      #     # RSpec
      #
      #     describe User do
      #       it { should validate_length_of(:bio).is_at_least(15) }
      #     end
      #
      #     # Minitest (Shoulda)
      #
      #     class UserTest < ActiveSupport::TestCase
      #       should validate_length_of(:bio).is_at_least(15)
      #     end
      #
      # ##### is_at_most
      #
      # Use `is_at_most` to test usage of the `:maximum` option. This asserts
      # that the attribute can take a string which is equal to or shorter than
      # the given length and cannot take a string which is longer.
      #
      #     class User
      #       include ActiveModel::Model
      #       attr_accessor :status_update
      #
      #       validates_length_of :status_update, maximum: 140
      #     end
      #
      #     # RSpec
      #     describe User do
      #       it { should validate_length_of(:status_update).is_at_most(140) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserTest < ActiveSupport::TestCase
      #       should validate_length_of(:status_update).is_at_most(140)
      #     end
      #
      # ##### is_equal_to
      #
      # Use `is_equal_to` to test usage of the `:is` option. This asserts that
      # the attribute can take a string which is exactly equal to the given
      # length and cannot take a string which is shorter or longer.
      #
      #     class User
      #       include ActiveModel::Model
      #       attr_accessor :favorite_superhero
      #
      #       validates_length_of :favorite_superhero, is: 6
      #     end
      #
      #     # RSpec
      #     describe User do
      #       it { should validate_length_of(:favorite_superhero).is_equal_to(6) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserTest < ActiveSupport::TestCase
      #       should validate_length_of(:favorite_superhero).is_equal_to(6)
      #     end
      #
      # ##### is_at_least + is_at_most
      #
      # Use `is_at_least` and `is_at_most` together to test usage of the `:in`
      # option.
      #
      #     class User
      #       include ActiveModel::Model
      #       attr_accessor :password
      #
      #       validates_length_of :password, in: 5..30
      #     end
      #
      #     # RSpec
      #     describe User do
      #       it do
      #         should validate_length_of(:password).
      #           is_at_least(5).is_at_most(30)
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserTest < ActiveSupport::TestCase
      #       should validate_length_of(:password).
      #         is_at_least(5).is_at_most(30)
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
      #       validates_length_of :password,
      #         minimum: 10,
      #         message: "Password isn't long enough"
      #     end
      #
      #     # RSpec
      #     describe User do
      #       it do
      #         should validate_length_of(:password).
      #           is_at_least(10).
      #           with_message("Password isn't long enough")
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserTest < ActiveSupport::TestCase
      #       should validate_length_of(:password).
      #         is_at_least(10).
      #         with_message("Password isn't long enough")
      #     end
      #
      # ##### with_short_message
      #
      # Use `with_short_message` if you are using a custom "too short" message.
      #
      #     class User
      #       include ActiveModel::Model
      #       attr_accessor :secret_key
      #
      #       validates_length_of :secret_key,
      #         in: 15..100,
      #         too_short: 'Secret key must be more than 15 characters'
      #     end
      #
      #     # RSpec
      #     describe User do
      #       it do
      #         should validate_length_of(:secret_key).
      #           is_at_least(15).
      #           with_short_message('Secret key must be more than 15 characters')
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserTest < ActiveSupport::TestCase
      #       should validate_length_of(:secret_key).
      #         is_at_least(15).
      #         with_short_message('Secret key must be more than 15 characters')
      #     end
      #
      # ##### with_long_message
      #
      # Use `with_long_message` if you are using a custom "too long" message.
      #
      #     class User
      #       include ActiveModel::Model
      #       attr_accessor :secret_key
      #
      #       validates_length_of :secret_key,
      #         in: 15..100,
      #         too_long: 'Secret key must be less than 100 characters'
      #     end
      #
      #     # RSpec
      #     describe User do
      #       it do
      #         should validate_length_of(:secret_key).
      #           is_at_most(100).
      #           with_long_message('Secret key must be less than 100 characters')
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserTest < ActiveSupport::TestCase
      #       should validate_length_of(:secret_key).
      #         is_at_most(100).
      #         with_long_message('Secret key must be less than 100 characters')
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
      #     class User
      #       include ActiveModel::Model
      #       attr_accessor :password
      #
      #       validates_length_of :password, minimum: 10
      #
      #       def password=(value)
      #         @password = value.upcase
      #       end
      #     end
      #
      #     # RSpec
      #     describe User do
      #       it do
      #         should validate_length_of(:password).
      #           is_at_least(10).
      #           ignoring_interference_by_writer
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserTest < ActiveSupport::TestCase
      #       should validate_length_of(:password).
      #         is_at_least(10).
      #         ignoring_interference_by_writer
      #     end
      #
      # @return [ValidateLengthOfMatcher]
      #
      def validate_length_of(attr)
        ValidateLengthOfMatcher.new(attr)
      end

      # @private
      class ValidateLengthOfMatcher < ValidationMatcher
        include Helpers

        def initialize(attribute)
          super(attribute)
          @options = {}
          @short_message = nil
          @long_message = nil
        end

        def is_at_least(length)
          @options[:minimum] = length
          @short_message ||= :too_short
          self
        end

        def is_at_most(length)
          @options[:maximum] = length
          @long_message ||= :too_long
          self
        end

        def is_equal_to(length)
          @options[:minimum] = length
          @options[:maximum] = length
          @short_message ||= :wrong_length
          @long_message ||= :wrong_length
          self
        end

        def with_message(message)
          if message
            @expects_custom_validation_message = true
            @short_message = message
            @long_message = message
          end

          self
        end

        def with_short_message(message)
          if message
            @expects_custom_validation_message = true
            @short_message = message
          end

          self
        end

        def with_long_message(message)
          if message
            @expects_custom_validation_message = true
            @long_message = message
          end

          self
        end

        def simple_description
          description = "validate that the length of :#{@attribute}"

          if @options.key?(:minimum) && @options.key?(:maximum)
            if @options[:minimum] == @options[:maximum]
              description << " is #{@options[:minimum]}"
            else
              description << " is between #{@options[:minimum]}"
              description << " and #{@options[:maximum]}"
            end
          elsif @options.key?(:minimum)
            description << " is at least #{@options[:minimum]}"
          elsif @options.key?(:maximum)
            description << " is at most #{@options[:maximum]}"
          end

          description
        end

        def matches?(subject)
          super(subject)
          translate_messages!
          lower_bound_matches? && upper_bound_matches?
        end

        private

        def translate_messages!
          if Symbol === @short_message
            @short_message = default_error_message(@short_message,
                                                   model_name: @subject.class.to_s.underscore,
                                                   instance: @subject,
                                                   attribute: @attribute,
                                                   count: @options[:minimum])
          end

          if Symbol === @long_message
            @long_message = default_error_message(@long_message,
                                                  model_name: @subject.class.to_s.underscore,
                                                  instance: @subject,
                                                  attribute: @attribute,
                                                  count: @options[:maximum])
          end
        end

        def lower_bound_matches?
          disallows_lower_length? && allows_minimum_length?
        end

        def upper_bound_matches?
          disallows_higher_length? && allows_maximum_length?
        end

        def disallows_lower_length?
          if @options.key?(:minimum)
            @options[:minimum] == 0 ||
              disallows_length_of?(@options[:minimum] - 1, @short_message)
          else
            true
          end
        end

        def disallows_higher_length?
          if @options.key?(:maximum)
            disallows_length_of?(@options[:maximum] + 1, @long_message)
          else
            true
          end
        end

        def allows_minimum_length?
          if @options.key?(:minimum)
            allows_length_of?(@options[:minimum], @short_message)
          else
            true
          end
        end

        def allows_maximum_length?
          if @options.key?(:maximum)
            allows_length_of?(@options[:maximum], @long_message)
          else
            true
          end
        end

        def allows_length_of?(length, message)
          allows_value_of(string_of_length(length), message)
        end

        def disallows_length_of?(length, message)
          disallows_value_of(string_of_length(length), message)
        end

        def string_of_length(length)
          'x' * length
        end
      end
    end
  end
end
