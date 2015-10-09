module Shoulda
  module Matchers
    module Integrations
      # @private
      module Inclusion
        def self.resolve_to_constant(constant_name)
          constant_name_pieces = constant_name.sub(/\A::/, '').split('::')

          constant_name_pieces.reduce(Object) do |constant, part|
            constant.const_get(part.to_sym)
          end
        rescue NameError
          nil
        end

        def self.resolves_to_constant?(constant_name)
          !resolve_to_constant(constant_name).nil?
        end

        def include_into(target_modules, source_modules, options = {}, &block)
          modules_to_include = target_modules.dup
          modules_to_extend = target_modules.dup

          if block
            modules_to_include << Module.new(&block)
          end

          target_modules.each do |mod|
            mod.__send__(:include, *modules_to_include)
          end

          if options[:extend]
            target_modules.each do |mod|
              mod.extend(*modules_to_extend)
            end
          end
        end

        def inclusion_targets
          @_inclusion_targets ||= inclusion_target_names.map do |class_name|
            Inclusion.resolve_to_constant(class_name)
          end
        end

        def find_first_missing_inclusion_target
          inclusion_target_names.detect do |name|
            !Inclusion.resolves_to_constant?(name)
          end
        end
      end
    end
  end
end
