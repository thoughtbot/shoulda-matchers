module Shoulda
  module Matchers
    module ActionController
      # @private
      class Store
        NO_KEY_SET = Object.new
        private_constant :NO_KEY_SET

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

        def has_value?(expected_value, key = NO_KEY_SET)
          values = key.equal?(NO_KEY_SET) ? store.values : [store[key.to_s]]
          values.any? do |actual_value|
            expected_value === actual_value
          end
        end

        def empty?
          store.empty?
        end
      end
    end
  end
end
