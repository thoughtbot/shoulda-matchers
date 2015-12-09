module Shoulda
  module Matchers
    module ActionController
      # @private
      class Store
        attr_accessor :controller

        def name
          raise NotImplementedError, 'must be implemented by subclass'
        end

        def store
          raise NotImplementedError, 'must be implemented by subclass'
        end

        def has_key?(key)
          store.has_key?(key.to_s)
        end

        def has_value?(expected_value)
          store.values.any? { |actual_value| expected_value === actual_value }
        end

        def has_key_value?(expected_key, expected_value)
          return false unless has_key?(expected_key)
          expected_value === store[expected_key.to_s]
        end

        def empty?
          store.empty?
        end
      end
    end
  end
end
