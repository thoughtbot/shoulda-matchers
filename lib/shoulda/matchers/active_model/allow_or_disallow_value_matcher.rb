module Shoulda
  module Matchers
    module ActiveModel
      # @private
      class AllowOrDisallowValueMatcher
        include Helpers
        include Qualifiers::IgnoringInterferenceByWriter

        attr_reader(
          :after_setting_value_callback,
          :attribute_to_check_message_against,
          :attribute_to_set,
          :context,
          :subject,
        )

        attr_writer(
          :attribute_changed_value_message,
          :failure_message_preface,
          :values_to_preset,
        )

        def initialize(*values, part_of_larger_matcher: false)
          super
          @values_to_set = values
          @options = {}
          @after_setting_value_callback = -> {}
          @expects_strict = false
          @expects_custom_validation_message = false
          @context = nil
          @values_to_preset = {}
          @failure_message_preface = nil
          @attribute_changed_value_message = nil
          @was_negated = nil
          @part_of_larger_matcher = part_of_larger_matcher
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

        def _after_setting_value(&callback)
          @after_setting_value_callback = callback
        end

        def was_negated?
          @was_negated
        end

        def part_of_larger_matcher?
          @part_of_larger_matcher
        end

        def include_attribute_changed_value_message?
          !ignore_interference_by_writer.never? &&
            result.attribute_setter.attribute_changed_value?
        end

        def attribute_changed_value_message
          stored_attribute_changed_value_message.call
        end

        def description
          ValidationMatcher::BuildDescription.call(self, simple_description)
        end

        def model
          subject.class
        end

        def last_attribute_setter_used
          result.attribute_setter
        end

        def last_value_set
          last_attribute_setter_used.value_written
        end

        def pretty_print(pp)
          Shoulda::Matchers::Util.pretty_print(self, pp, {
            was_negated: was_negated?,
            attribute_to_set: attribute_to_set,
            attribute_to_check_message_against: attribute_to_check_message_against,
            values_to_set: values_to_set,
            expected_message: expected_message,
            expects_strict: expects_strict?,
            subject: subject,
            attribute_setters_and_validators_for_values_to_set: attribute_setters_and_validators_for_values_to_set,
          })
        end

        protected

        attr_reader(
          :options,
          :result,
          :values_to_preset,
          :values_to_set,
        )

        def matches?(subject)
          @subject = subject
          @was_negated = false
          false
        end

        def does_not_match?(subject)
          @subject = subject
          @was_negated = true
          false
        end

        def positive_failure_message
          attribute_setter = result.attribute_setter

          if result.attribute_setter.successfully_checked?
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
          else
            message = attribute_setter.failure_message
          end

          if !part_of_larger_matcher? && include_attribute_changed_value_message?
            message << "\n\n" + attribute_changed_value_message
          end

          Shoulda::Matchers.word_wrap(message)
        end

        def negative_failure_message
          attribute_setter = result.attribute_setter

          if attribute_setter.successfully_checked?
            validator = result.validator
            message = failure_message_preface.call + ' invalid'

            if validator.validation_message_type_matches?
              if validator.has_matching_validation_messages?
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
                  message << ' matching '
                  message << Shoulda::Matchers::Util.inspect_value(
                    expected_message,
                  )
                else
                  message << " #{expected_message.inspect}"
                end

                if !validator.captured_validation_exception?
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
          else
            message = attribute_setter.failure_message
          end

          if !part_of_larger_matcher? && include_attribute_changed_value_message?
            message << "\n\n" + attribute_changed_value_message
          end

          Shoulda::Matchers.word_wrap(message)
        end

        private

        def run(strategy)
          attribute_setters_for_values_to_preset.first_to_unexpectedly_not_pass ||
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

        def stored_attribute_changed_value_message
          @attribute_changed_value_message ||
            method(:default_attribute_changed_value_message)
        end

        def default_attribute_changed_value_message
          <<-MESSAGE.strip
As indicated above, :#{result.attribute_setter.attribute_name} seems to be
changing certain values as they are set, and this could have something to do
with why this test is failing. If you've overridden the writer method for this
attribute, then you may need to change it to make this test pass. Otherwise, you
may need to do something else entirely.
          MESSAGE
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
              values_to_set.map { |value| [attribute_to_set, value] },
            )
        end

        def inspected_values_to_set
          Shoulda::Matchers::Util.inspect_values(values_to_set).to_sentence(
            two_words_connector: ' or ',
            last_word_connector: ', or ',
          )
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
            default_attribute_message_values,
          )
        end

        def default_attribute_message_values
          defaults = {
            model_name: model_name,
            model: subject,
            attribute: attribute_to_check_message_against,
          }

          defaults.merge(options[:expected_message_values])
        end

        def model_name
          subject.class.to_s.underscore
        end

        def human_attribute_name
          subject.class.human_attribute_name(attribute_to_check_message_against)
        end
      end
    end
  end
end
