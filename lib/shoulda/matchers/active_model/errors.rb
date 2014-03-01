module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      class CouldNotDetermineValueOutsideOfArray < RuntimeError; end

      class NonNullableBooleanError < Shoulda::Matchers::Error; end

      class CouldNotClearAttribute < Shoulda::Matchers::Error
        def self.create(actual_value)
          super(actual_value: actual_value)
        end

        attr_accessor :actual_value

        def message
          "Expected value to be nil, but was #{actual_value.inspect}."
        end
      end

      class CouldNotSetPasswordError < Shoulda::Matchers::Error
        def self.create(model)
          super(model: model)
        end

        attr_accessor :model

        def message
          <<-EOT.strip
The validation failed because your #{model_name} model declares `has_secure_password`, and
`validate_presence_of` was called on a #{record_name} which has `password` already set to a value.
Please use a #{record_name} with an empty `password` instead.
          EOT
        end

        private

        def model_name
          model.name
        end

        def record_name
          model_name.humanize.downcase
        end
      end
    end
  end
end
