module Shoulda
  module Matchers
    module ActiveRecord
      # @private
      module Uniqueness
        # @private
        module TestModels
          # Test models subclass real ActiveRecord models, so they register
          # in `descendants`/`subclasses` and cannot be unregistered after
          # the fact: ActiveSupport::DescendantsTracker.clear raises when
          # config.enable_reloading is false (the default in the test
          # environment), and the classes cannot be reliably garbage
          # collected. Instead, mirror the filtering technique Rails itself
          # uses for reloaded classes and hide them at the source.
          module DescendantsFiltering
            def descendants
              super.reject { |klass| TestModels.contains?(klass) }
            end

            def subclasses
              super.reject { |klass| TestModels.contains?(klass) }
            end
          end

          def self.create(model_name)
            hide_from_descendants
            TestModelCreator.create(model_name, root_namespace)
          end

          def self.remove_all
            root_namespace.clear
          end

          def self.root_namespace
            @_root_namespace ||= Namespace.new(self)
          end

          def self.contains?(klass)
            !klass.name.nil? && klass.name.start_with?(name_prefix)
          end

          def self.name_prefix
            @_name_prefix ||= "#{name}::"
          end

          def self.hide_from_descendants
            @_hide_from_descendants ||=
              ::ActiveRecord::Base.singleton_class.
                prepend(DescendantsFiltering) && true
          end
        end
      end
    end
  end
end
