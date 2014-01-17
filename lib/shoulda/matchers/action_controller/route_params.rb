module Shoulda # :nodoc:
  module Matchers
    module ActionController # :nodoc:
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

        private

        attr_reader :args

        def controller_and_action_given_as_string?
          args[0].is_a?(String)
        end

        def extract_params_from_string
          params = args[1] || {}
          controller, action = args[0].split('#')
          params.merge!(controller: controller, action: action)
        end

        def stringify_params
          args[0].each do |key, value|
            args[0][key] = stringify(value)
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
