module Shoulda
  module Matchers
    module Doublespeak
      # @private
      module DoubleImplementationRegistry
        class << self
          # rubocop:disable Style/MutableConstant
          REGISTRY = {}
          # rubocop:enable Style/MutableConstant

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
