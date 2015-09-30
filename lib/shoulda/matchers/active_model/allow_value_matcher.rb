module Shoulda
  module Matchers
    module ActiveModel
      # The `allow_value` matcher (or its alias, `allow_values`) is used to
      # ensure that an attribute is valid or invalid if set to one or more
      # values.
      #
      # Take this model for example:
      #
      #     class UserProfile
      #       include ActiveModel::Model
      #       attr_accessor :website_url
      #
      #       validates_format_of :website_url, with: URI.regexp
      #     end
      #
      # You can use `allow_value` to test one value at a time:
      #
      #     # RSpec
      #     describe UserProfile do
      #       it { should allow_value('http://foo.com').for(:website_url) }
      #       it { should allow_value('http://bar.com').for(:website_url) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserProfileTest < ActiveSupport::TestCase
      #       should allow_value('http://foo.com').for(:website_url)
      #       should allow_value('http://bar.com').for(:website_url)
      #     end
      #
      # You can also test multiple values in one go, if you like. In the
      # positive sense, this makes an assertion that none of the values cause the
      # record to be invalid. In the negative sense, this makes an assertion
      # that none of the values cause the record to be valid:
      #
      #     # RSpec
      #     describe UserProfile do
      #       it do
      #         should allow_values('http://foo.com', 'http://bar.com').
      #           for(:website_url)
      #       end
      #
      #       it do
      #         should_not allow_values('http://foo.com', 'buz').
      #           for(:website_url)
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserProfileTest < ActiveSupport::TestCase
      #       should allow_values('http://foo.com', 'http://bar.com/baz').
      #         for(:website_url)
      #
      #       should_not allow_values('http://foo.com', 'buz').
      #         for(:website_url)
      #     end
      #
      # #### Caveats
      #
      # When using `allow_value` or any matchers that depend on it, you may
      # encounter a CouldNotSetAttributeError. This exception is raised if the
      # matcher, in attempting to set a value on the attribute, detects that
      # the value set is different from the value that the attribute returns
      # upon reading it back.
      #
      # This usually happens if the writer method (`foo=`, `bar=`, etc.) for
      # that attribute has custom logic to ignore certain incoming values or
      # change them in any way. Here are three examples we've seen:
      #
      # * You're attempting to assert that an attribute should not allow nil,
      #   yet the attribute's writer method contains a conditional to do nothing
      #   if the attribute is set to nil:
      #
      #         class Foo
      #           include ActiveModel::Model
      #
      #           attr_reader :bar
      #
      #           def bar=(value)
      #             return if value.nil?
      #             @bar = value
      #           end
      #         end
      #
      #         describe Foo do
      #           it do
      #             foo = Foo.new
      #             foo.bar = "baz"
      #             # This will raise a CouldNotSetAttributeError since `foo.bar` is now "123"
      #             expect(foo).not_to allow_value(nil).for(:bar)
      #           end
      #         end
      #
      # * You're attempting to assert that an numeric attribute should not allow a
      #   string that contains non-numeric characters, yet the writer method for
      #   that attribute strips out non-numeric characters:
      #
      #         class Foo
      #           include ActiveModel::Model
      #
      #           attr_reader :bar
      #
      #           def bar=(value)
      #             @bar = value.gsub(/\D+/, '')
      #           end
      #         end
      #
      #         describe Foo do
      #           it do
      #             foo = Foo.new
      #             # This will raise a CouldNotSetAttributeError since `foo.bar` is now "123"
      #             expect(foo).not_to allow_value("abc123").for(:bar)
      #           end
      #         end
      #
      # * You're passing a value to `allow_value` that the model typecasts into
      #   another value:
      #
      #         describe Foo do
      #           # Assume that `attr` is a string
      #           # This will raise a CouldNotSetAttributeError since `attr` typecasts `[]` to `"[]"`
      #           it { should_not allow_value([]).for(:attr) }
      #         end
      #
      # So when you encounter this exception, you have a couple of options:
      #
      # * If you understand the problem and wish to override this behavior to
      #   get around this exception, you can add the
      #   `ignoring_interference_by_writer` qualifier like so:
      #
      #         it do
      #           should_not allow_value([]).
      #             for(:attr).
      #             ignoring_interference_by_writer
      #         end
      #
      # * Note, however, that the above option will not always cause the test to
      #   pass. In this case, this is telling you that you don't need to use
      #   `allow_value`, or quite possibly even the validation that you're
      #   testing altogether. In any case, we would probably make the argument
      #   that since it's clear that something is responsible for sanitizing
      #   incoming data before it's stored in your model, there's no need to
      #   ensure that sanitization places the model in a valid state, if such
      #   sanitization creates valid data. In terms of testing, the sanitization
      #   code should probably be tested, but not the effects of that
      #   sanitization on the validness of the model.
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
      #     # Minitest (Shoulda)
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
      #     # Minitest (Shoulda)
      #     class UserProfileTest < ActiveSupport::TestCase
      #       should allow_value('open', 'closed').
      #         for(:state).
      #         with_message('State must be open or closed')
      #     end
      #
      # Use `with_message` with a regexp to perform a partial match:
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
      #           with_message(/open or closed/)
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserProfileTest < ActiveSupport::TestCase
      #       should allow_value('open', 'closed').
      #         for(:state).
      #         with_message(/open or closed/)
      #     end
      #
      # Use `with_message` with the `:against` option if the attribute the
      # validation message is stored under is different from the attribute
      # being validated:
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
      #     # Minitest (Shoulda)
      #     class UserProfileTest < ActiveSupport::TestCase
      #       should allow_value('Broncos', 'Titans').
      #         for(:sports_team).
      #         with_message('Must be either a Broncos or Titans fan',
      #           against: :chosen_sports_team
      #         )
      #     end
      #
      # ##### ignoring_interference_by_writer
      #
      # Use `ignoring_interference_by_writer` if you've encountered a
      # CouldNotSetAttributeError and wish to ignore it. Please read the Caveats
      # section above for more information.
      #
      #     class Address < ActiveRecord::Base
      #       # Address has a zip_code field which is a string
      #     end
      #
      #     # RSpec
      #     describe Address do
      #       it do
      #         should_not allow_value([]).
      #         for(:zip_code).
      #         ignoring_interference_by_writer
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class AddressTest < ActiveSupport::TestCase
      #       should_not allow_value([]).
      #       for(:zip_code).
      #       ignoring_interference_by_writer
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
      alias_method :allow_values, :allow_value

      # @private
      class AllowValueMatcher
        # @private
        class CouldNotSetAttributeError < Shoulda::Matchers::Error
          def self.create(model, attribute, expected_value, actual_value)
            super(
              model: model,
              attribute: attribute,
              expected_value: expected_value,
              actual_value: actual_value
            )
          end

          attr_accessor :model, :attribute, :expected_value, :actual_value

          def message
            "Expected #{model.class} to be able to set #{attribute} to #{expected_value.inspect}, but got #{actual_value.inspect} instead."
          end
        end

        include Helpers

        attr_accessor :attribute_with_message
        attr_accessor :options

        def initialize(*values)
          self.values_to_match = values
          self.options = {}
          self.after_setting_value_callback = -> {}
          self.validator = Validator.new
          @ignoring_interference_by_writer = false
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

        def ignoring_interference_by_writer
          @ignoring_interference_by_writer = true
          self
        end

        def _after_setting_value(&callback)
          self.after_setting_value_callback = callback
        end

        def matches?(instance)
          self.instance = instance
          values_to_match.all? { |value| value_matches?(value) }
        end

        def does_not_match?(instance)
          self.instance = instance
          values_to_match.all? { |value| !value_matches?(value) }
        end

        def failure_message
          "Did not expect #{expectation},\ngot#{error_description}"
        end

        def failure_message_when_negated
          "Expected #{expectation},\ngot#{error_description}"
        end

        def description
          validator.allow_description(allowed_values)
        end

        protected

        attr_reader :instance, :attribute_to_check_message_against
        attr_accessor :values_to_match, :attribute_to_set, :value,
          :matched_error, :after_setting_value_callback, :validator

        def instance=(instance)
          @instance = instance
          validator.record = instance
        end

        def attribute_to_check_message_against=(attribute)
          @attribute_to_check_message_against = attribute
          validator.attribute = attribute
        end

        def ignoring_interference_by_writer?
          @ignoring_interference_by_writer
        end

        def value_matches?(value)
          self.value = value
          set_attribute(value)
          !(errors_match? || any_range_error_occurred?)
        end

        def set_attribute(value)
          instance.__send__("#{attribute_to_set}=", value)
          ensure_that_attribute_was_set!(value)
          after_setting_value_callback.call
        end

        def ensure_that_attribute_was_set!(expected_value)
          actual_value = instance.__send__(attribute_to_set)

          if expected_value != actual_value && !ignoring_interference_by_writer?
            raise CouldNotSetAttributeError.create(
              instance.class,
              attribute_to_set,
              expected_value,
              actual_value
            )
          end
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
