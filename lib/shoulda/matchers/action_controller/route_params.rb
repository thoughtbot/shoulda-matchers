module Shoulda
  module Matchers
    module ActionController
      # @private
      class RouteParams
        def initialize(args)
          @args = args
        end

        def normalize
          if controller_and_action_given_as_string?
            extract_params_from_string
          else
            stringify_params
          end
        end

        protected

        attr_reader :args

        def controller_and_action_given_as_string?
          args[0].is_a?(String)
        end

        def extract_params_from_string
          controller, action = args[0].split('#')
          params = (args[1] || {}).merge(controller: controller, action: action)
          stringify_values(params)
        end

        def stringify_params
          stringify_values(args[0])
        end

        def stringify_values(hash)
          hash.inject({}) do |hash_copy, (key, value)|
            hash_copy[key] = stringify(value)
            hash_copy
          end
        end

        def stringify(value)
          if value.is_a?(Array)
            value.map(&:to_param)
          else
            value.to_param
          end
        end
      end
    end
  end
end
