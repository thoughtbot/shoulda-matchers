require 'active_resource'

module UnitTests
  module ActiveResourceBuilder
    def self.configure_example_group(example_group)
      example_group.include ActiveResourceBuilder

      example_group.after do
        ActiveSupport::Dependencies.clear
      end
    end

    def define_active_resource_class(class_name, attributes = {}, &block)
      define_class(class_name, ActiveResource::Base) do
        schema do
          attributes.each do |attr, type|
            attribute attr, type
          end
        end

        if block_given?
          class_eval(&block)
        end
      end
    end
  end
end
