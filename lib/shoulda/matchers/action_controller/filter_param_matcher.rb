module Shoulda
  module Matchers
    module ActionController
      # The `filter_param` matcher is used to test parameter filtering
      # configuration. Specifically, it asserts that the given parameter is
      # present in `config.filter_parameters`.
      #
      #     class MyApplication < Rails::Application
      #       config.filter_parameters << :secret_key
      #     end
      #
      #     # RSpec
      #     describe ApplicationController do
      #       it { should filter_param(:secret_key) }
      #     end
      #
      #     # Test::Unit
      #     class ApplicationControllerTest < ActionController::TestCase
      #       should filter_param(:secret_key)
      #     end
      #
      # @return [FilterParamMatcher]
      #
      def filter_param(key)
        FilterParamMatcher.new(key)
      end

      # @private
      class FilterParamMatcher
        def initialize(key)
          @key = key
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
          filtered_keys.any? do |filter|
            case filter
            when Regexp
              filter =~ @key
            else
              filter == @key
            end
          end
        end

        def filtered_keys
          Rails.application.config.filter_parameters
        end
      end
    end
  end
end
