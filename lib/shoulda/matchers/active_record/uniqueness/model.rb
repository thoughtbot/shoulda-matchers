module Shoulda
  module Matchers
    module ActiveRecord
      # @private
      module Uniqueness
        # @private
        class Model
          def self.next_unique_copy_of(model_name, namespace)
            model = new(model_name, namespace)

            while model.already_exists?
              model = model.next
            end

            model
          end

          def initialize(name, namespace)
            @name = name
            @namespace = namespace
          end

          def already_exists?
            namespace.has?(name)
          end

          def next
            Model.new(name.next, namespace)
          end

          def symlink_to(parent)
            table_name = parent.table_name

            new_class = Class.new(parent) do
              define_singleton_method :table_name do
                table_name
              end

              define_singleton_method :base_class do
                self
              end
            end

            namespace.set(name, new_class)
          end

          def to_s
            [namespace, name].join('::')
          end

          protected

          attr_reader :name, :namespace
        end
      end
    end
  end
end
