module Shoulda
  module Matchers
    module Doublespeak
      module DoubleImplementationRegistry
        class << self
          REGISTRY = {}

          def find(type)
            find_class!(type).create
          end

          def register(klass, type)
            REGISTRY[type] = klass
          end

          private

          def find_class!(type)
            REGISTRY.fetch(type) do
              raise ArgumentError, "No double implementation class found for '#{type}'"
            end
          end
        end
      end
    end
  end
end
