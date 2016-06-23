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

      # @private
      class NoRangeOrArrayDefinedForInclusionError < Shoulda::Matchers::Error
        def self.create(attribute)
          super(attribute: attribute)
        end

        attr_accessor :attribute

        def message
          <<-EOT.strip
You are using the `validate_inclusion_of` matcher without specifying the values that the matcher should use to test the inclusion validation. You'll need to provide the matcher with either a range or an array. For instance:
  should validate_inclusion_of(:#{attribute}).in_range(0..10)
  should validate_inclusion_of(:#{attribute}).in_array(['one', 'two', 'three'])
          EOT
        end
      end
    end
  end
end
