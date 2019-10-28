module UnitTests
  module ClassBuilder
    def define_module(*args, &block)
      ClassBuilder.define_module(*args, &block)
    end

    def define_class(*args, &block)
      ClassBuilder.define_class(*args, &block)
    end

    class << self
      def configure_example_group(example_group)
        example_group.include(self)

        example_group.after do
          ClassBuilder.reset
        end
      end

      def reset
        remove_defined_modules
        defined_modules.clear
      end

      def define_module(module_name, &block)
        module_name = module_name.to_s.camelize
        namespace, name_without_namespace = parse_constant_name(module_name)

        remove_defined_module(module_name)

        eval <<-RUBY
          module #{namespace}::#{name_without_namespace}
          end
        RUBY

        namespace.const_get(name_without_namespace).tap do |constant|
          constant.unloadable
          @_defined_modules = defined_modules | [constant]

          if block
            constant.module_eval(&block)
          end
        end
      end

      def define_class(class_name, parent_class = Object, &block)
        class_name = class_name.to_s.camelize
        namespace, name_without_namespace = parse_constant_name(class_name)

        remove_defined_module(class_name)

        eval <<-RUBY
          class #{namespace}::#{name_without_namespace} < ::#{parent_class}
          end
        RUBY

        namespace.const_get(name_without_namespace).tap do |constant|
          constant.unloadable
          @_defined_modules = defined_modules | [constant]

          if block
            if block.arity == 0
              constant.class_eval(&block)
            else
              block.call(constant)
            end
          end
        end
      end

      def parse_constant_name(name)
        namespace = Shoulda::Matchers::Util.deconstantize(name)
        qualified_namespace = (namespace.presence || 'Object').constantize
        name_without_namespace = name.to_s.demodulize
        [qualified_namespace, name_without_namespace]
      end

      private

      def remove_defined_modules
        defined_modules.reverse_each { |mod| remove_defined_module(mod.name) }
        ActiveSupport::Dependencies.clear
      end

      def remove_defined_module(module_name)
        namespace, name_without_namespace = parse_constant_name(module_name)

        if namespace.const_defined?(name_without_namespace, false)
          namespace.__send__(:remove_const, name_without_namespace)
        end
      end

      def defined_modules
        @_defined_modules ||= []
      end
    end
  end
end
