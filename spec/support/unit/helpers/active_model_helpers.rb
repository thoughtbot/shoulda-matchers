module UnitTests
  module ActiveModelHelpers
    def self.configure_example_group(example_group)
      example_group.include(self)
    end

    def custom_validation(options = {}, &block)
      attribute_name = options.fetch(:attribute_name, :attr)
      attribute_type = options.fetch(:attribute_type, :integer)

      define_model(:example, attribute_name => attribute_type) do
        validate :custom_validation

        define_method(:custom_validation, &block)
      end.new
    end
    alias record_with_custom_validation custom_validation

    def validating_format(options)
      define_model :example, attr: :string do
        validates_format_of :attr, options
      end.new
    end
  end
end
