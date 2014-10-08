module ClassBuilder
  def self.included(example_group)
    example_group.class_eval do
      after do
        teardown_defined_constants
      end
    end
  end

  def self.parse_constant_name(name)
    namespace = Shoulda::Matchers::Util.deconstantize(name)
    qualified_namespace = (namespace.presence || 'Object').constantize
    name_without_namespace = name.to_s.demodulize
    [qualified_namespace, name_without_namespace]
  end

  def define_class(class_name, parent_class = Object, &block)
    class_name = class_name.to_s.camelize

    namespace, name_without_namespace =
      ClassBuilder.parse_constant_name(class_name)

    if namespace.const_defined?(name_without_namespace, false)
      namespace.__send__(:remove_const, name_without_namespace)
    end

    eval <<-RUBY
      class #{namespace}::#{name_without_namespace} < #{parent_class}
      end
    RUBY

    namespace.const_get(name_without_namespace).tap do |constant|
      constant.unloadable

      if block_given?
        constant.class_eval(&block)
      end

      if constant.respond_to?(:reset_column_information)
        constant.reset_column_information
      end
    end
  end

  def teardown_defined_constants
    ActiveSupport::Dependencies.clear
  end
end

RSpec.configure do |config|
  config.include ClassBuilder
end
