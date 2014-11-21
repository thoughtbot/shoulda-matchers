module Shoulda
  module Matchers
    module ActionController
      # The `set_session` matcher is used to make assertions about the
      # `session` hash.
      #
      #     class PostsController < ApplicationController
      #       def index
      #         session[:foo] = 'A candy bar'
      #       end
      #
      #       def destroy
      #       end
      #     end
      #
      #     # RSpec
      #     describe PostsController do
      #       describe 'GET #index' do
      #         before { get :index }
      #
      #         it { should set_session }
      #       end
      #
      #       describe 'DELETE #destroy' do
      #         before { delete :destroy }
      #
      #         it { should_not set_session }
      #       end
      #     end
      #
      #     # Test::Unit
      #     class PostsControllerTest < ActionController::TestCase
      #       context 'GET #index' do
      #         setup { get :index }
      #
      #         should set_session
      #       end
      #
      #       context 'DELETE #destroy' do
      #         setup { delete :destroy }
      #
      #         should_not set_session
      #       end
      #     end
      #
      # #### Qualifiers
      #
      # ##### []
      #
      # Use `[]` to narrow the scope of the matcher to a particular key.
      #
      #     class PostsController < ApplicationController
      #       def index
      #         session[:foo] = 'A candy bar'
      #       end
      #     end
      #
      #     # RSpec
      #     describe PostsController do
      #       describe 'GET #index' do
      #         before { get :index }
      #
      #         it { should set_session[:foo] }
      #         it { should_not set_session[:bar] }
      #       end
      #     end
      #
      #     # Test::Unit
      #     class PostsControllerTest < ActionController::TestCase
      #       context 'GET #index' do
      #         setup { get :show }
      #
      #         should set_session[:foo]
      #         should_not set_session[:bar]
      #       end
      #     end
      #
      # ##### to
      #
      # Use `to` to assert that some key was set to a particular value, or that
      # some key matches a particular regex.
      #
      #     class PostsController < ApplicationController
      #       def index
      #         session[:foo] = 'A candy bar'
      #       end
      #     end
      #
      #     # RSpec
      #     describe PostsController do
      #       describe 'GET #index' do
      #         before { get :index }
      #
      #         it { should set_session.to('A candy bar') }
      #         it { should set_session.to(/bar/) }
      #         it { should set_session[:foo].to('bar') }
      #         it { should_not set_session[:foo].to('something else') }
      #       end
      #     end
      #
      #     # Test::Unit
      #     class PostsControllerTest < ActionController::TestCase
      #       context 'GET #index' do
      #         setup { get :show }
      #
      #         should set_session.to('A candy bar')
      #         should set_session.to(/bar/)
      #         should set_session[:foo].to('bar')
      #         should_not set_session[:foo].to('something else')
      #       end
      #     end
      #
      # @return [SetSessionMatcher]
      #
      def set_session(key = nil)
        SetSessionMatcher.new(key)
      end

      # @private
      class SetSessionMatcher
        def initialize(key)
          if key
            Shoulda::Matchers.warn <<EOT
Passing a key to set_session is deprecated.
Please use the hash syntax instead (e.g., `set_session[:foo]`, not `set_session(:foo)`).
EOT
            self[key]
          end

          @value_block = nil
        end

        def [](key)
          @key = key.to_s
          self
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

          if nil_value_expected_but_actual_value_unset?
            Shoulda::Matchers.warn <<EOT
Using `should set_session[...].to(nil)` to assert that a variable is unset is deprecated.
Please use `should_not set_session[...]` instead.
EOT
          end

          if key_specified? && value_specified?
            @value === session[@key]
          elsif key_specified?
            session.key?(@key)
          elsif value_specified?
            session.values.any? { |value| @value === value }
          else
            session_present?
          end
        end

        def failure_message
          "Expected #{expectation}, but #{result}"
        end
        alias failure_message_for_should failure_message

        def failure_message_when_negated
          "Didn't expect #{expectation}, but it was"
        end
        alias failure_message_for_should_not failure_message_when_negated

        def description
          "should #{expectation}"
        end

        def in_context(context)
          @context = context
          self
        end

        private

        def key_specified?
          defined?(@key)
        end

        def value_specified?
          defined?(@value)
        end

        def value_or_default_value
          defined?(@value) && @value
        end

        def nil_value_expected_but_actual_value_unset?
          value_specified? && @value.nil? && !session.key?(@key)
        end

        def session_present?
          !session.empty?
        end

        def expectation
          expectation = ""

          if key_specified?
            expectation << "session variable #{@key.inspect}"
          else
            expectation << "any session variable"
          end

          expectation << " to be"

          if value_specified? && !@value.nil?
            expectation << " #{@value.inspect}"
          else
            expectation << " set"
          end

          expectation
        end

        def result
          if session_present?
            "the session was #{session.inspect}"
          else
            'no session variables were set'
          end
        end

        def session
          @controller.session
        end
      end
    end
  end
end
