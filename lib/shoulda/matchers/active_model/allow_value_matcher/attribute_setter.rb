module Shoulda
  module Matchers
    module ActiveModel
      class AllowValueMatcher
        # @private
        class AttributeSetter
          def self.set(args)
            new(args).set
          end

          attr_reader :result_of_checking, :result_of_setting,
            :value_written

          def initialize(args)
            @matcher_name = args.fetch(:matcher_name)
            @object = args.fetch(:object)
            @attribute_name = args.fetch(:attribute_name)
            @value_written = args.fetch(:value)
            @ignoring_interference_by_writer =
              args.fetch(:ignoring_interference_by_writer, false)
            @after_set_callback = args.fetch(:after_set_callback, -> { })

            @result_of_checking = nil
            @result_of_setting = nil
          end

          def description
            description = ":#{attribute_name} to "
            description << Shoulda::Matchers::Util.inspect_value(value_written)

            if attribute_changed_value?
              description << " -- which was read back as "
              description << Shoulda::Matchers::Util.inspect_value(value_read)
              description << " --"
            end

            description
          end

          def run
            check && set
          end

          def run!
            check && set!
          end

          def check
            if attribute_exists?
              @result_of_checking = successful_check
              true
            else
              @result_of_checking = attribute_does_not_exist_error
              false
            end
          end

          def set!
            if attribute_exists?
              set

              unless result_of_setting.successful?
                raise result_of_setting
              end

              @result_of_checking = successful_check
              @result_of_setting = successful_setting

              true
            else
              attribute_does_not_exist!
            end
          end

          def set
            object.public_send("#{attribute_name}=", value_written)
            after_set_callback.call

            @result_of_checking = successful_check

            if attribute_changed_value? && !ignoring_interference_by_writer?
              @result_of_setting = attribute_changed_value_error
              false
            else
              @result_of_setting = successful_setting
              true
            end
          end

          def failure_message
            if successful?
              raise "We're not supposed to be here!"
            elsif result_of_setting
              result_of_setting.message
            else
              result_of_checking.message
            end
          end

          def successful?
            successfully_checked? && successfully_set?
          end

          def unsuccessful?
            !successful?
          end

          def checked?
            !result_of_checking.nil?
          end

          def successfully_checked?
            checked? && result_of_checking.successful?
          end

          def unsuccessfully_checked?
            !successfully_checked?
          end

          def set?
            !result_of_setting.nil?
          end

          def successfully_set?
            set? && result_of_setting.successful?
          end

          protected

          attr_reader :matcher_name, :object, :attribute_name,
            :after_set_callback

          private

          def model
            object.class
          end

          def attribute_exists?
            if active_resource_object?
              object.known_attributes.include?(attribute_name.to_s)
            else
              object.respond_to?("#{attribute_name}=")
            end
          end

          def attribute_changed_value?
            value_written != value_read
          end

          def value_read
            @_value_read ||= object.public_send(attribute_name)
          end

          def ignoring_interference_by_writer?
            !!@ignoring_interference_by_writer
          end

          def successful_check
            SuccessfulCheck.new
          end

          def successful_setting
            SuccessfulSetting.new
          end

          def attribute_changed_value!
            raise attribute_changed_value_error
          end

          def attribute_changed_value_error
            AttributeChangedValueError.create(
              model: object.class,
              attribute_name: attribute_name,
              value_written: value_written,
              value_read: value_read
            )
          end

          def attribute_does_not_exist!
            raise attribute_does_not_exist_error
          end

          def attribute_does_not_exist_error
            AttributeDoesNotExistError.create(
              model: object.class,
              attribute_name: attribute_name,
              value: value_written
            )
          end

          def active_resource_object?
            object.respond_to?(:known_attributes)
          end
        end
      end
    end
  end
end
