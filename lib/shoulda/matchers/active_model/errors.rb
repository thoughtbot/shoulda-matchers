module Shoulda
  module Matchers
    module ActiveModel
      # @private
      class CouldNotDetermineValueOutsideOfArray < RuntimeError; end

      # @private
      class NonNullableBooleanError < Shoulda::Matchers::Error
        def self.create(attribute)
          super(attribute: attribute)
        end

        attr_accessor :attribute

        def message
          <<-EOT.strip
You have specified that your model's #{attribute} should ensure inclusion of nil.
However, #{attribute} is a boolean column which does not allow null values.
Hence, this test will fail and there is no way to make it pass.
          EOT
        end
      end

      # @private
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

      class CouldNotValidateCaseError < Shoulda::Matchers::Error
        def self.create(record, attribute)
          super(record: record, attribute: attribute)
        end

        attr_accessor :record, :attribute

        def message
          <<-EOT.strip
Your #{model} model has a uniqueness validation on :#{attribute} which is
declared to be case-sensitive, but the value the uniqueness matcher used,
"#{value}", doesn't contain any alpha characters, so using it to test the
case-sensitivity part of the validation is ineffective. There are two possible
solutions for this depending on what you're trying to do here:

If you meant for the validation to be case-sensitive,
then you need to give the uniqueness matcher a saved instance of #{model} with a
value for :#{attribute} that contains alpha characters.

If you meant for the validation to be case-insensitive,
then you need to add `case_sensitive: false` to the validation and add
case_insensitive to the matcher.

For full examples, please see:

http://github.com/thoughtbot/shoulda-matchers/wiki/error-uniques
          EOT
        end

        private

        def model
          record.class
        end

        def value
          record.__send__(@attribute)
        end
      end
    end
  end
end
