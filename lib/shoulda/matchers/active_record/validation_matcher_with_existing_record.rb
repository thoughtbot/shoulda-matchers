module Shoulda
  module Matchers
    module ActiveRecord
      class ValidationMatcherWithExistingRecord < Shoulda::Matchers::ActiveModel::ValidationMatcher
        include ActiveModel::Helpers

        def initialize(attribute)
          super(attribute)

          @existing_record_created = false
          @attribute_setters = {
            existing_record: UniqueAttributeSetters.new,
            new_record: UniqueAttributeSetters.new,
          }
        end

        protected

        alias_method :new_record, :subject

        def build_allow_or_disallow_value_matcher(args)
          super.tap do |matcher|
            matcher.expectation_preface = expectation_preface

            matcher.building_attribute_changed_value_message do
              attribute_changed_value_message
            end
          end
        end

        def update_existing_record!(value)
          if value_from_existing_record != value
            set_attribute_on_existing_record!(attribute, value)
            # It would be nice if we could ensure that the record was valid,
            # but that would break users' existing tests
            existing_record.save(validate: false)
          end
        end

        private

        attr_reader :attribute_setters

        def existing_record_created?
          @existing_record_created
        end

        def existing_record
          unless defined?(@_existing_record)
            find_or_create_existing_record
          end

          @_existing_record
        end

        def find_or_create_existing_record
          @_existing_record = find_existing_record

          if !@_existing_record
            @_existing_record = create_existing_record
            @existing_record_created = true
          end
        end

        def find_existing_record
          record = model.first

          if record.present?
            record
          else
            nil
          end
        end

        def create_existing_record
          given_record.tap do |existing_record|
            ensure_secure_password_set_on(existing_record)
            existing_record.save(validate: false)
          end
        rescue ::ActiveRecord::StatementInvalid => error
          raise ExistingRecordInvalid.create(underlying_exception: error)
        end

        def ensure_secure_password_set_on(instance)
          if has_secure_password?
            instance.password = 'password'
            instance.password_confirmation = 'password'
          end
        end

        def has_secure_password?
          model.ancestors.map(&:to_s).include?(
            'ActiveModel::SecurePassword::InstanceMethodsOnActivation',
          )
        end

        def set_attribute_on_existing_record!(attribute_name, value)
          set_attribute_on!(
            :existing_record,
            existing_record,
            attribute_name,
            value,
          )
        end

        def set_attribute_on_new_record!(attribute_name, value)
          set_attribute_on!(
            :new_record,
            subject,
            attribute_name,
            value,
          )
        end

        def set_attribute_on!(record_type, record, attribute_name, value)
          attribute_setter = build_attribute_setter(
            record,
            attribute_name,
            value,
          )
          attribute_setter.set!

          attribute_setters[record_type] << attribute_setter
        end

        def attribute_setter_for_existing_record
          attribute_setters[:existing_record].last
        end

        def attribute_setters_for_new_record
          attribute_setters[:new_record] +
            [last_attribute_setter_used_on_new_record]
        end

        def build_attribute_setter(record, attribute_name, value)
          Shoulda::Matchers::ActiveModel::AllowValueMatcher::AttributeSetter.new(
            matcher_name: :validate_uniqueness_of,
            object: record,
            attribute_name: attribute_name,
            value: value,
            ignore_interference_by_writer: ignore_interference_by_writer,
          )
        end

        def value_from_existing_record
          existing_record.public_send(attribute)
        end

        def existing_value_written
          if attribute_setter_for_existing_record
            attribute_setter_for_existing_record.value_written
          else
            value_from_existing_record
          end
        end

        def expectation_preface
          prefix = ''

          if existing_record_created?
            prefix << "After taking the given #{model.name}"

            if attribute_setter_for_existing_record
              prefix << ', setting '
              prefix << description_for_attribute_setter(
                attribute_setter_for_existing_record,
              )
            else
              prefix << ", whose :#{attribute} is "
              prefix << "‹#{value_from_existing_record.inspect}›"
            end

            prefix << ', and saving it as the existing record, then'
          elsif attribute_setter_for_existing_record
            prefix << "Given an existing #{model.name},"
            prefix << ' after setting '
            prefix << description_for_attribute_setter(
              attribute_setter_for_existing_record,
            )
            prefix << ', then'
          else
            prefix << "Given an existing #{model.name} whose :#{attribute}"
            prefix << ' is '
            prefix << Shoulda::Matchers::Util.inspect_value(
              value_from_existing_record,
            )
            prefix << ', after'
          end

          prefix << " making a new #{model.name} and setting "

          prefix << descriptions_for_attribute_setters_for_new_record

          prefix << ", the new #{model.name} was expected "
        end

        def description_for_attribute_setter(attribute_setter, same_as_existing: nil)
          description = "its :#{attribute_setter.attribute_name} to "

          if same_as_existing == false
            description << 'a different value, '
          end

          description << Shoulda::Matchers::Util.inspect_value(
            attribute_setter.value_written,
          )

          if attribute_setter.attribute_changed_value?
            description << ' (read back as '
            description << Shoulda::Matchers::Util.inspect_value(
              attribute_setter.value_read,
            )
            description << ')'
          end

          if same_as_existing == true
            description << ' as well'
          end

          description
        end

        def descriptions_for_attribute_setters_for_new_record
          attribute_setter_descriptions_for_new_record.to_sentence
        end

        def attribute_setter_descriptions_for_new_record
          attribute_setters_for_new_record.map do |attribute_setter|
            same_as_existing = (
              attribute_setter.value_written ==
              existing_value_written
            )
            description_for_attribute_setter(
              attribute_setter,
              same_as_existing: same_as_existing,
            )
          end
        end

        def existing_and_new_values_are_same?
          last_value_set_on_new_record == existing_value_written
        end

        def attribute_changed_value_message
          <<-MESSAGE.strip
As indicated in the message above, :#{attribute} seems to be changing
certain values as they are set, and this could have something to do with
why this test is failing. If you or something else has overridden the
writer method for this attribute to normalize values by changing their
case in any way (for instance, ensuring that the attribute is always
downcased), then try adding `ignoring_case_sensitivity` onto the end of
the uniqueness matcher. Otherwise, you may need to write the test
yourself, or do something different altogether.
          MESSAGE
        end

        # FIXME: last_submatcher_run probably won't work
        def last_attribute_setter_used_on_new_record
          last_submatcher_run.last_attribute_setter_used
        end

        # FIXME: last_submatcher_run probably won't work
        def last_value_set_on_new_record
          last_submatcher_run.last_value_set
        end

        # @private
        class UniqueAttributeSetters
          include Enumerable

          def initialize
            @attribute_setters = []
          end

          def <<(given_attribute_setter)
            index = find_index_of(given_attribute_setter)

            if index
              attribute_setters[index] = given_attribute_setter
            else
              attribute_setters << given_attribute_setter
            end
          end

          def +(other_attribute_setters)
            dup.tap do |attribute_setters|
              other_attribute_setters.each do |attribute_setter|
                attribute_setters << attribute_setter
              end
            end
          end

          def each(&block)
            attribute_setters.each(&block)
          end

          def last
            attribute_setters.last
          end

          private

          def find_index_of(given_attribute_setter)
            attribute_setters.find_index do |attribute_setter|
              attribute_setter.attribute_name ==
                given_attribute_setter.attribute_name
            end
          end
        end

        # @private
        class ExistingRecordInvalid < Shoulda::Matchers::Error
          include Shoulda::Matchers::ActiveModel::Helpers

          attr_accessor :underlying_exception

          def message
            <<-MESSAGE.strip
validate_uniqueness_of works by matching a new record against an
existing record. If there is no existing record, it will create one
using the record you provide.

While doing this, the following error was raised:

#{Shoulda::Matchers::Util.indent(underlying_exception.message, 2)}

The best way to fix this is to provide the matcher with a record where
any required attributes are filled in with valid values beforehand.
            MESSAGE
          end
        end
      end
    end
  end
end
