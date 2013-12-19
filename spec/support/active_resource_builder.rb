require 'active_resource'

module ActiveResourceBuilder
  def self.included(example_group)
    example_group.class_eval do
      after do
        ActiveSupport::Dependencies.clear
      end
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

RSpec.configure do |config|
  config.include ActiveResourceBuilder
end
