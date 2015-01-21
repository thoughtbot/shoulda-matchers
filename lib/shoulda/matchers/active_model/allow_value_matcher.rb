module Shoulda
  module Matchers
    module ActiveModel
      # The `allow_value` matcher is used to test that an attribute of a model
      # can or cannot be set to a particular value or values. It is most
      # commonly used in conjunction with the `validates_format_of` validation.
      #
      # #### should
      #
      # In the positive form, `allow_value` asserts that an attribute can be
      # set to one or more values, succeeding if none of the values cause the
      # record to be invalid:
      #
      #     class UserProfile
      #       include ActiveModel::Model
      #       attr_accessor :website_url
      #
      #       validates_format_of :website_url, with: URI.regexp
      #     end
      #
      #     # RSpec
      #     describe UserProfile do
      #       it do
      #         should allow_value('http://foo.com', 'http://bar.com/baz').
      #           for(:website_url)
      #       end
      #     end
      #
      #     # Test::Unit
      #     class UserProfileTest < ActiveSupport::TestCase
      #       should allow_value('http://foo.com', 'http://bar.com/baz').
      #         for(:website_url)
      #     end
      #
      # #### should_not
      #
      # In the negative form, `allow_value` asserts that an attribute cannot be
      # set to one or more values, succeeding if the *first* value causes the
      # record to be invalid.
      #
      # **This can be surprising** so in this case if you need to check that
      # *all* of the values are invalid, use separate assertions:
      #
      #     class UserProfile
      #       include ActiveModel::Model
      #       attr_accessor :website_url
      #
      #       validates_format_of :website_url, with: URI.regexp
      #     end
      #
      #     describe UserProfile do
      #       # One assertion: 'buz' and 'bar' will not be tested
      #       it { should_not allow_value('fiz', 'buz', 'bar').for(:website_url) }
      #
      #       # Three assertions, all tested separately
      #       it { should_not allow_value('fiz').for(:website_url) }
      #       it { should_not allow_value('buz').for(:website_url) }
      #       it { should_not allow_value('bar').for(:website_url) }
      #     end
      #
      # #### Qualifiers
      #
      # ##### on
      #
      # Use `on` if your validation applies only under a certain context.
      #
      #     class UserProfile
      #       include ActiveModel::Model
      #       attr_accessor :birthday_as_string
      #
      #       validates_format_of :birthday_as_string,
      #         with: /^(\d+)-(\d+)-(\d+)$/,
      #         on: :create
      #     end
      #
      #     # RSpec
      #     describe UserProfile do
      #       it do
      #         should allow_value('2013-01-01').
      #           for(:birthday_as_string).
      #           on(:create)
      #       end
      #     end
      #
      #     # Test::Unit
      #     class UserProfileTest < ActiveSupport::TestCase
      #       should allow_value('2013-01-01').
      #         for(:birthday_as_string).
      #         on(:create)
      #     end
      #
      # ##### with_message
      #
      # Use `with_message` if you are using a custom validation message.
      #
      #     class UserProfile
      #       include ActiveModel::Model
      #       attr_accessor :state
      #
      #       validates_format_of :state,
      #         with: /^(open|closed)$/,
      #         message: 'State must be open or closed'
      #     end
      #
      #     # RSpec
      #     describe UserProfile do
      #       it do
      #         should allow_value('open', 'closed').
      #           for(:state).
      #           with_message('State must be open or closed')
      #       end
      #     end
      #
      #     # Test::Unit
      #     class UserProfileTest < ActiveSupport::TestCase
      #       should allow_value('open', 'closed').
      #         for(:state).
      #         with_message('State must be open or closed')
      #     end
      #
      # Use `with_message` with the `:against` option if the attribute the
      # validation message is stored under is different from the attribute
      # being validated.
      #
      #     class UserProfile
      #       include ActiveModel::Model
      #       attr_accessor :sports_team
      #
      #       validate :sports_team_must_be_valid
      #
      #       private
      #
      #       def sports_team_must_be_valid
      #         if sports_team !~ /^(Broncos|Titans)$/i
      #           self.errors.add :chosen_sports_team,
      #             'Must be either a Broncos fan or a Titans fan'
      #         end
      #       end
      #     end
      #
      #     # RSpec
      #     describe UserProfile do
      #       it do
      #         should allow_value('Broncos', 'Titans').
      #           for(:sports_team).
      #           with_message('Must be either a Broncos or Titans fan',
      #             against: :chosen_sports_team
      #           )
      #       end
      #     end
      #
      #     # Test::Unit
      #     class UserProfileTest < ActiveSupport::TestCase
      #       should allow_value('Broncos', 'Titans').
      #         for(:sports_team).
      #         with_message('Must be either a Broncos or Titans fan',
      #           against: :chosen_sports_team
      #         )
      #     end
      #
      # @return [AllowValueMatcher]
      #
      def allow_value(*values)
        if values.empty?
          raise ArgumentError, 'need at least one argument'
        else
          AllowValueMatcher.new(*values)
        end
      end

      # @private
      class AllowValueMatcher
        include Helpers

        attr_accessor :attribute_with_message
        attr_accessor :options

        def initialize(*values)
          self.values_to_match = values
          self.options = {}
          self.after_setting_value_callback = -> {}
          self.validator = Validator.new
        end

        def for(attribute)
          self.attribute_to_set = attribute
          self.attribute_to_check_message_against = attribute
          self
        end

        def on(context)
          validator.context = context
          self
        end

        def with_message(message, options={})
          self.options[:expected_message] = message
          self.options[:expected_message_values] = options.fetch(:values, {})

          if options.key?(:against)
            self.attribute_to_check_message_against = options[:against]
          end

          self
        end

        def strict
          validator.strict = true
          self
        end

        def _after_setting_value(&callback)
          self.after_setting_value_callback = callback
        end

        def matches?(instance)
          self.instance = instance
          validator.record = instance

          values_to_match.none? do |value|
            validator.reset
            self.value = value
            set_attribute(value)
            errors_match? || any_range_error_occurred?
          end
        end

        def failure_message
          "Did not expect #{expectation},\ngot#{error_description}"
        end
        alias failure_message_for_should failure_message

        def failure_message_when_negated
          "Expected #{expectation},\ngot#{error_description}"
        end
        alias failure_message_for_should_not failure_message_when_negated

        def description
          validator.allow_description(allowed_values)
        end

        protected

        attr_reader :attribute_to_check_message_against
        attr_accessor :values_to_match, :instance, :attribute_to_set, :value,
          :matched_error, :after_setting_value_callback, :validator

        def attribute_to_check_message_against=(attribute)
          @attribute_to_check_message_against = attribute
          validator.attribute = attribute
        end

        def set_attribute(value)
          set_attribute_ignoring_range_errors(value)
          after_setting_value_callback.call
        end

        def set_attribute_ignoring_range_errors(value)
          instance.__send__("#{attribute_to_set}=", value)
        rescue RangeError => exception
          # Have to reset the attribute so that we don't get a RangeError the
          # next time we attempt to write the attribute (ActiveRecord seems to
          # set the attribute to the "bad" value anyway)
          reset_attribute
          validator.capture_range_error(exception)
        end

        def reset_attribute
          instance.send(:raw_write_attribute, attribute_to_set, nil)
        end

        def errors_match?
          has_messages? && errors_for_attribute_match?
        end

        def has_messages?
          validator.has_messages?
        end

        def errors_for_attribute_match?
          if expected_message
            self.matched_error = errors_match_regexp? || errors_match_string?
          else
            errors_for_attribute.compact.any?
          end
        end

        def errors_for_attribute
          validator.formatted_messages
        end

        def errors_match_regexp?
          if Regexp === expected_message
            errors_for_attribute.detect { |e| e =~ expected_message }
          end
        end

        def errors_match_string?
          if errors_for_attribute.include?(expected_message)
            expected_message
          end
        end

        def any_range_error_occurred?
          validator.captured_range_error?
        end

        def expectation
          parts = [
            expected_messages_description,
            "when #{attribute_to_set} is set to #{value.inspect}"
          ]

          parts.join(' ').squeeze(' ')
        end

        def expected_messages_description
          validator.expected_messages_description(expected_message)
        end

        def error_description
          validator.messages_description
        end

        def allowed_values
          if values_to_match.length > 1
            "any of [#{values_to_match.map(&:inspect).join(', ')}]"
          else
            values_to_match.first.inspect
          end
        end

        def expected_message
          if options.key?(:expected_message)
            if Symbol === options[:expected_message]
              default_expected_message
            else
              options[:expected_message]
            end
          end
        end

        def default_expected_message
          validator.expected_message_from(default_attribute_message)
        end

        def default_attribute_message
          default_error_message(
            options[:expected_message],
            default_attribute_message_values
          )
        end

        def default_attribute_message_values
          defaults = {
            model_name: model_name,
            instance: instance,
            attribute: attribute_to_check_message_against,
          }

          defaults.merge(options[:expected_message_values])
        end

        def model_name
          instance.class.to_s.underscore
        end
      end
    end
  end
end
