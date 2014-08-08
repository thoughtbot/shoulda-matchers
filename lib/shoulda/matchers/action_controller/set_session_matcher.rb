module Shoulda
  module Matchers
    module ActionController
      # The `set_session` matcher is used to make assertions about the
      # `session` hash.
      #
      #     class PostsController < ApplicationController
      #       def show
      #         session[:foo] = 'bar'
      #       end
      #     end
      #
      #     # RSpec
      #     describe PostsController do
      #       describe 'GET #show' do
      #         before { get :show }
      #
      #         it { should set_session(:foo) }
      #         it { should_not set_session(:baz) }
      #       end
      #     end
      #
      #     # Test::Unit
      #     class PostsControllerTest < ActionController::TestCase
      #       context 'GET #show' do
      #         setup { get :show }
      #
      #         should set_session(:foo)
      #         should_not set_session(:baz)
      #       end
      #     end
      #
      # #### Qualifiers
      #
      # ##### to
      #
      # Use `to` to assert that the key in the session hash was set to a
      # particular value.
      #
      #     class PostsController < ApplicationController
      #       def index
      #         session[:foo] = 'bar'
      #       end
      #
      #       def show
      #         session[:foo] = nil
      #       end
      #     end
      #
      #     # RSpec
      #     describe PostsController do
      #       describe 'GET #index' do
      #         before { get :index }
      #
      #         it { should set_session(:foo).to('bar') }
      #         it { should_not set_session(:foo).to('something else') }
      #         it { should_not set_session(:foo).to(nil) }
      #       end
      #
      #       describe 'GET #show' do
      #         before { get :show }
      #
      #         it { should set_session(:foo).to(nil) }
      #       end
      #     end
      #
      #     # Test::Unit
      #     class PostsControllerTest < ActionController::TestCase
      #       context 'GET #index' do
      #         setup { get :index }
      #
      #         should set_session(:foo).to('bar')
      #         should_not set_session(:foo).to('something else')
      #         should_not set_session(:foo).to(nil)
      #       end
      #
      #       context 'GET #show' do
      #         setup { get :show }
      #
      #         should set_session(:foo).to(nil)
      #       end
      #     end
      #
      # @return [SetSessionMatcher]
      #
      def set_session(key)
        SetSessionMatcher.new(key)
      end

      # @private
      class SetSessionMatcher
        def initialize(key)
          @key = key.to_s
          @value_block = nil
        end

        def to(value = nil, &block)
          @value = value
          @value_block = block
          self
        end

        def matches?(controller)
          @controller = controller
          if @value_block
            @value = @context.instance_eval(&@value_block)
          end
          assigned_correct_value? || cleared_value?
        end

        def failure_message
          "Expected #{expectation}, but #{result}"
        end
        alias failure_message_for_should failure_message

        def failure_message_when_negated
          "Didn't expect #{expectation}, but #{result}"
        end
        alias failure_message_for_should_not failure_message_when_negated

        def description
          description = "set session variable #{@key.inspect}"
          if @value
            description << " to #{@value.inspect}"
          end
          description
        end

        def in_context(context)
          @context = context
          self
        end

        private

        def value_or_default_value
          defined?(@value) && @value
        end

        def assigned_value?
          !assigned_value.nil?
        end

        def cleared_value?
          defined?(@value) && @value.nil? && assigned_value.nil?
        end

        def assigned_correct_value?
          if assigned_value?
            if !defined?(@value)
              true
            else
              assigned_value == value_or_default_value
            end
          end
        end

        def assigned_value
          session[@key]
        end

        def expectation
          expectation = "session variable #{@key} to be set"

          if value_or_default_value
            expectation << " to #{value_or_default_value.inspect}"
          end
        end

        def result
          if session.empty?
            'no session variables were set'
          else
            "the session was #{session.inspect}"
          end
        end

        def session
          if @controller.request.respond_to?(:session)
            @controller.request.session.to_hash
          else
            @controller.response.session.data
          end
        end
      end
    end
  end
end
