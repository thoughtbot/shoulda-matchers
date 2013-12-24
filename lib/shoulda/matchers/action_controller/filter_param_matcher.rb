module Shoulda # :nodoc:
  module Matchers
    module ActionController # :nodoc:
      # Ensures that filter_parameter_logging is set for the specified key.
      #
      # Example:
      #
      #   it { should filter_param(:password) }
      def filter_param(key)
        FilterParamMatcher.new(key)
      end

      class FilterParamMatcher # :nodoc:
        def initialize(key)
          @key = key.to_s
        end

        def matches?(controller)
          filters_key?
        end

        def failure_message
          "Expected #{@key} to be filtered; filtered keys: #{filtered_keys.join(', ')}"
        end
        alias failure_message_for_should failure_message

        def failure_message_when_negated
          "Did not expect #{@key} to be filtered"
        end
        alias failure_message_for_should_not failure_message_when_negated

        def description
          "filter #{@key}"
        end

        private

        def filters_key?
          filtered_keys.include?(@key)
        end

        def filtered_keys
          Rails.application.config.filter_parameters.map(&:to_s)
        end
      end
    end
  end
end
