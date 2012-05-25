module Shoulda
  module Matchers
    module ActiveModel
      class FormattedErrorMessageList

        def initialize(instance)
          @instance = instance
        end

        def errors_when(attribute_hash)
          attribute_hash.each do |attribute, value|
            @instance.send("#{attribute}=", value)
          end
          pretty_errors
        end

        private

        def pretty_errors
          errors.map do |attribute, error_message|
            FormattedErrorMessage.new(attribute, error_message).message
          end
        end

        def errors
          validate
          @instance.errors
        end

        def validate
          @instance.valid?
        end
      end
    end
  end
end
