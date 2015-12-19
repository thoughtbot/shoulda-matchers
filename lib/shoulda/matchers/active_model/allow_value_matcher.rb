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
      # * You're attempting to assert that a numeric attribute should not allow
      #   a string that contains non-numeric characters, yet the writer method
      #   for that attribute strips out non-numeric characters:
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
        include Helpers

        attr_reader(
          :after_setting_value_callback,
          :attribute_to_check_message_against,
          :attribute_to_set,
          :context,
          :instance
        )

        attr_writer :failure_message_preface, :values_to_preset

        def initialize(*values)
          @values_to_set = values
          @options = {}
          @after_setting_value_callback = -> {}
          @ignoring_interference_by_writer = false
          @expects_strict = false
          @expects_custom_validation_message = false
          @context = nil
          @values_to_preset = {}
          @failure_message_preface = nil
        end

        def for(attribute_name)
          @attribute_to_set = attribute_name
          @attribute_to_check_message_against = attribute_name
          self
        end

        def on(context)
          if context.present?
            @context = context
          end

          self
        end

        def with_message(message, given_options = {})
          if message.present?
            @expects_custom_validation_message = true
            options[:expected_message] = message
            options[:expected_message_values] = given_options.fetch(:values, {})

            if given_options.key?(:against)
              @attribute_to_check_message_against = given_options[:against]
            end
          end

          self
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

        def expects_custom_validation_message?
          @expects_custom_validation_message
        end

        def strict(expects_strict = true)
          @expects_strict = expects_strict
          self
        end

        def expects_strict?
          @expects_strict
        end

        def ignoring_interference_by_writer(value = true)
          @ignoring_interference_by_writer = value
          self
        end

        def ignoring_interference_by_writer?
          @ignoring_interference_by_writer
        end

        def _after_setting_value(&callback)
          @after_setting_value_callback = callback
        end

        def matches?(instance)
          @instance = instance
          @result = run(:first_failing)
          @result.nil?
        end

        def does_not_match?(instance)
          @instance = instance
          @result = run(:first_passing)
          @result.nil?
        end

        def failure_message
          attribute_setter = result.attribute_setter

          if result.attribute_setter.unsuccessfully_checked?
            message = attribute_setter.failure_message
          else
            validator = result.validator
            message = failure_message_preface.call
            message << ' valid, but it was invalid instead,'

            if validator.captured_validation_exception?
              message << ' raising a validation exception with the message '
              message << validator.validation_exception_message.inspect
              message << '.'
            else
              message << " producing these validation errors:\n\n"
              message << validator.all_formatted_validation_error_messages
            end
          end

          Shoulda::Matchers.word_wrap(message)
        end

        def failure_message_when_negated
          attribute_setter = result.attribute_setter

          if attribute_setter.unsuccessfully_checked?
            message = attribute_setter.failure_message
          else
            validator = result.validator
            message = failure_message_preface.call + ' invalid'

            if validator.type_of_message_matched?
              if validator.has_messages?
                message << ' and to'

                if validator.captured_validation_exception?
                  message << ' raise a validation exception with message'
                else
                  message << ' produce'

                  if expected_message.is_a?(Regexp)
                    message << ' a'
                  else
                    message << ' the'
                  end

                  message << ' validation error'
                end

                if expected_message.is_a?(Regexp)
                  message << ' matching'
                end

                message << " #{expected_message.inspect}"

                unless validator.captured_validation_exception?
                  message << " on :#{attribute_to_check_message_against}"
                end

                message << '. The record was indeed invalid, but'

                if validator.captured_validation_exception?
                  message << ' the exception message was '
                  message << validator.validation_exception_message.inspect
                  message << ' instead.'
                else
                  message << " it produced these validation errors instead:\n\n"
                  message << validator.all_formatted_validation_error_messages
                end
              else
                message << ', but it was valid instead.'
              end
            elsif validator.captured_validation_exception?
              message << ' and to produce validation errors, but the record'
              message << ' raised a validation exception instead.'
            else
              message << ' and to raise a validation exception, but the record'
              message << ' produced validation errors instead.'
            end
          end

          Shoulda::Matchers.word_wrap(message)
        end

        def description
          ValidationMatcher::BuildDescription.call(self, simple_description)
        end

        def simple_description
          "allow :#{attribute_to_set} to be #{inspected_values_to_set}"
        end

        def model
          instance.class
        end

        def last_value_set
          result.attribute_setter.value_written
        end

        protected

        attr_reader(
          :options,
          :result,
          :values_to_preset,
          :values_to_set,
        )

        private

        def run(strategy)
          attribute_setters_for_values_to_preset.first_failing ||
            attribute_setters_and_validators_for_values_to_set.public_send(strategy)
        end

        def failure_message_preface
          @failure_message_preface || method(:default_failure_message_preface)
        end

        def default_failure_message_preface
          ''.tap do |preface|
            if descriptions_for_preset_values.any?
              preface << 'After setting '
              preface << descriptions_for_preset_values.to_sentence
              preface << ', then '
            else
              preface << 'After '
            end

            preface << 'setting '
            preface << description_for_resulting_attribute_setter

            unless preface.end_with?('--')
              preface << ','
            end

            preface << " the matcher expected the #{model.name} to be"
          end
        end

        def descriptions_for_preset_values
          attribute_setters_for_values_to_preset.
            map(&:attribute_setter_description)
        end

        def description_for_resulting_attribute_setter
          result.attribute_setter_description
        end

        def attribute_setters_for_values_to_preset
          @_attribute_setters_for_values_to_preset ||=
            AttributeSetters.new(self, values_to_preset)
        end

        def attribute_setters_and_validators_for_values_to_set
          @_attribute_setters_and_validators_for_values_to_set ||=
            AttributeSettersAndValidators.new(
              self,
              values_to_set.map { |value| [attribute_to_set, value] }
            )
        end

        def inspected_values_to_set
          if values_to_set.size > 1
            values_to_set.map(&:inspect).to_sentence(
              two_words_connector: " or ",
              last_word_connector: ", or"
            )
          else
            values_to_set.first.inspect
          end
        end

        def default_expected_message
          if expects_strict?
            "#{human_attribute_name} #{default_attribute_message}"
          else
            default_attribute_message
          end
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

        def human_attribute_name
          instance.class.human_attribute_name(
            attribute_to_check_message_against
          )
        end
      end
    end
  end
end
