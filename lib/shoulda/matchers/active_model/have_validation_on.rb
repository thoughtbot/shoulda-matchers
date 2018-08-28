module Shoulda
  module Matchers
    module ActiveModel
      # @private
      class HaveValidationOn
        def initialize(attribute_name, validator_class, short_validator_name)
          @attribute_name = attribute_name
          @validator_class = validator_class
          @short_validator_name = short_validator_name
        end

        def matches?(record)
          @record = record

          validations_on_attribute.any?
        end

        def expectation_description
          "Expected #{model} to have " +
            "#{Shoulda::Matchers::Util.a_or_an(short_validator_name)} " +
            "validation on :#{attribute_name}."
        end

        def aberration_description
          "However, it did not."
        end

        private

        attr_reader :attribute_name, :validator_class, :short_validator_name,
          :record

        def validations_on_attribute
          model._validators[attribute_name].grep(validator_class)
        end

        def model
          record.class
        end
      end
    end
  end
end
