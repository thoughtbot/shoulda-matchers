module Shoulda
  module Matchers
    module ActiveRecord
      class ValidationMatcherWithExistingRecord < Shoulda::Matchers::ActiveModel::ValidationMatcher
        include ActiveModel::Helpers

        def initialize(attribute)
          super(attribute)

          @existing_record_created = false
          @attribute_setters = {
            new_record: UniqueAttributeSetters.new,
            existing_record: UniqueAttributeSetters.new,
          }
        end

        def matches?(
          new_record:,
          existing_record:,
          existing_record_created:
        )
          @new_record = new_record
          @existing_record = existing_record
          @existing_record_created = existing_record_created

          super(new_record)
        # ensure
          # revert_new_record
          # revert_existing_record
        end

        protected

        def submatcher_matches?(submatcher)
          if submatcher.is_a?(ValidationMatcherWithExistingRecord)
            submatcher.matches?(
              new_record: new_record,
              existing_record: existing_record,
              existing_record_created: existing_record_created?,
            )
          else
            submatcher.matches?(existing_record)
          end
        end

        def build_allow_or_disallow_value_matcher(args)
          super.tap do |matcher|
            matcher.expectation_preface = expectation_preface

            matcher.building_attribute_changed_value_message do
              attribute_changed_value_message
            end
          end
        end

        def update_existing_record!(value)
          if current_value_from_existing_record != value
            set_attribute_on_existing_record!(attribute, value)
            # It would be nice if we could ensure that the record was valid,
            # but that would break users' existing tests
            existing_record.save(validate: false)
          end
        end

        private

        attr_reader :attribute_setters, :new_record, :existing_record,
          :original_values

        def existing_record_created?
          @existing_record_created
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

        def set_attribute_on_existing_record!(
          attribute_name,
          value,
          remember_setting: true
        )
          set_attribute_on!(
            :existing_record,
            existing_record,
            attribute_name,
            value,
            remember_setting: remember_setting,
          )
        end

        def set_attribute_on_new_record!(
          attribute_name,
          value,
          remember_setting: true
        )
          set_attribute_on!(
            :new_record,
            subject,
            attribute_name,
            value,
            remember_setting: remember_setting,
          )
        end

        def set_attribute_on!(
          record_type,
          record,
          attribute_name,
          value,
          remember_setting: true
        )
          attribute_setter = build_attribute_setter(
            record,
            attribute_name,
            value,
          )
          attribute_setter.set!

          if remember_setting
            puts "Setting :#{attribute_name} on #{record_type} to #{value.inspect}"
            attribute_setters[record_type] << attribute_setter
          end
        end

        def attribute_setters_for_existing_record
          attribute_setters.fetch(:existing_record)
        end

        def attribute_setters_for_new_record
          attribute_setters.fetch(:new_record)
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

        def original_values_for_existing_record
          attribute_setters_for_new_record.inject({}) do |hash, attribute_setter|
            if hash.key?(attribute_setter.attribute_name)
              hash
            else
              hash.merge(attribute_setter.attribute_name => attribute_setter.original_value)
            end
          end
        end

        def original_value_from_existing_record
          original_values_for_existing_record[attribute]
        end

        def current_value_from_existing_record
          existing_record.public_send(attribute)
        end

        def revert_new_record
          original_values[:new_record].each do |attribute_name, value|
            new_record.public_send("#{attribute_name}=", value)
          end
        end

        def revert_existing_record
          original_values[:existing_record].each do |attribute_name, value|
            existing_record.public_send("#{attribute_name}=", value)
          end

          existing_record.save(validate: false)
        end

        # def existing_value_written
          # if attribute_setter_for_existing_record
            # attribute_setter_for_existing_record.value_written
          # else
            # current_value_from_existing_record
          # end
        # end

        def expectation_preface
          prefix = ''

          if existing_record_created?
            prefix << "After taking the given #{model.name}"

            if attribute_setters_for_existing_record.any?
              prefix << ', setting its '
              prefix << descriptions_for_attribute_setters_for_existing_record
            else
              prefix << ", with its :#{attribute} set to "
              prefix << "‹#{original_value_from_existing_record.inspect}›"
            end

            prefix << ', and saving it as the existing record, then '
          elsif attribute_setters_for_existing_record.any?
            prefix << "Given an existing #{model.name},"
            prefix << ' after setting its '
            prefix << descriptions_for_attribute_setters_for_existing_record
            prefix << ', then '
          else
            prefix << "Given an existing #{model.name}"

            if attribute_setters_for_new_record.any?
              prefix << ' with '

              prefix << original_values_for_existing_record.map { |attribute, value|
                "its :#{attribute} set to " +
                  Shoulda::Matchers::Util.inspect_value(value)
              }.to_sentence
            end

            prefix << ', after '
          end

          prefix << "making a new #{model.name}"

          if attribute_setters_for_new_record.any?
            prefix << ' and setting '
            prefix << descriptions_for_attribute_setters_for_new_record
          end

          prefix << ", the new #{model.name} was expected "
        end

        def description_for_attribute_setter(attribute_setter)#, same_as_existing: nil)
          description = "its :#{attribute_setter.attribute_name} to "

          # if same_as_existing == false
            # description << 'a different value, '
          # end

          description << Shoulda::Matchers::Util.inspect_value(
            attribute_setter.value_written,
          )

          if attribute_setter.attribute_changed_value?
            description << ' (which was read back as '
            description << Shoulda::Matchers::Util.inspect_value(
              attribute_setter.value_read,
            )
            description << ')'
          end

          # XXX
          # if same_as_existing == true
            # description << ' as well'
          # end

          description
        end

        def descriptions_for_attribute_setters_for_new_record
          attribute_setter_descriptions_for_new_record.to_sentence
        end

        def attribute_setter_descriptions_for_new_record
          attribute_setters_for_new_record.map do |attribute_setter|
            description_for_attribute_setter(attribute_setter)
          end
        end

        # def existing_and_new_values_are_same?
          # last_value_set_on_new_record == existing_value_written
        # end

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

        # # FIXME: last_submatcher_run probably won't work
        # def last_attribute_setter_used_on_new_record
          # last_submatcher_run.last_attribute_setter_used
        # end

        # # FIXME: last_submatcher_run probably won't work
        # def last_value_set_on_new_record
          # last_submatcher_run.last_value_set
        # end

        # @private
        class UniqueAttributeSetters
          include Enumerable

          def initialize
            @attribute_setters = []
          end

          def <<(attribute_setter)
            # index = find_index_of(attribute_setter)

            # if index
              # attribute_setters[index] = attribute_setter
            # else
              attribute_setters << attribute_setter
            # end
          end

          # def +(other_attribute_setters)
            # dup.tap do |attribute_setters|
              # other_attribute_setters.each do |attribute_setter|
                # attribute_setters << attribute_setter
              # end
            # end
          # end

          def each(&block)
            attribute_setters.each(&block)
          end

          def last
            attribute_setters.last
          end

          private

          attr_reader :attribute_setters

          def find_index_of(given_attribute_setter)
            attribute_setters.find_index do |attribute_setter|
              attribute_setter.attribute_name == given_attribute_setter.attribute_name
            end
          end
        end
      end
    end
  end
end
