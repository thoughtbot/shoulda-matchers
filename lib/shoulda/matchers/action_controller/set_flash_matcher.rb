require 'forwardable'

module Shoulda
  module Matchers
    module ActionController
      # The `set_flash` matcher is used to make assertions about the
      # `flash` hash.
      #
      #     class PostsController < ApplicationController
      #       def index
      #         flash[:foo] = 'A candy bar'
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
      #         it { should set_flash }
      #       end
      #
      #       describe 'DELETE #destroy' do
      #         before { delete :destroy }
      #
      #         it { should_not set_flash }
      #       end
      #     end
      #
      #     # Test::Unit
      #     class PostsControllerTest < ActionController::TestCase
      #       context 'GET #index' do
      #         setup { get :index }
      #
      #         should set_flash
      #       end
      #
      #       context 'DELETE #destroy' do
      #         setup { delete :destroy }
      #
      #         should_not set_flash
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
      #         flash[:foo] = 'A candy bar'
      #       end
      #     end
      #
      #     # RSpec
      #     describe PostsController do
      #       describe 'GET #index' do
      #         before { get :index }
      #
      #         it { should set_flash[:foo] }
      #         it { should_not set_flash[:bar] }
      #       end
      #     end
      #
      #     # Test::Unit
      #     class PostsControllerTest < ActionController::TestCase
      #       context 'GET #index' do
      #         setup { get :show }
      #
      #         should set_flash[:foo]
      #         should_not set_flash[:bar]
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
      #         flash[:foo] = 'A candy bar'
      #       end
      #     end
      #
      #     # RSpec
      #     describe PostsController do
      #       describe 'GET #index' do
      #         before { get :index }
      #
      #         it { should set_flash.to('A candy bar') }
      #         it { should set_flash.to(/bar/) }
      #         it { should set_flash[:foo].to('bar') }
      #         it { should_not set_flash[:foo].to('something else') }
      #       end
      #     end
      #
      #     # Test::Unit
      #     class PostsControllerTest < ActionController::TestCase
      #       context 'GET #index' do
      #         setup { get :show }
      #
      #         should set_flash.to('A candy bar')
      #         should set_flash.to(/bar/)
      #         should set_flash[:foo].to('bar')
      #         should_not set_flash[:foo].to('something else')
      #       end
      #     end
      #
      # ##### now
      #
      # Use `now` to change the scope of the matcher to use the "now" hash
      # instead of the usual "future" hash.
      #
      #     class PostsController < ApplicationController
      #       def show
      #         flash.now[:foo] = 'bar'
      #       end
      #     end
      #
      #     # RSpec
      #     describe PostsController do
      #       describe 'GET #show' do
      #         before { get :show }
      #
      #         it { should set_flash.now }
      #         it { should set_flash[:foo].now }
      #         it { should set_flash[:foo].to('bar').now }
      #       end
      #     end
      #
      #     # Test::Unit
      #     class PostsControllerTest < ActionController::TestCase
      #       context 'GET #index' do
      #         setup { get :show }
      #
      #         should set_flash.now
      #         should set_flash[:foo].now
      #         should set_flash[:foo].to('bar').now
      #       end
      #     end
      #
      # @return [SetFlashMatcher]
      #
      def set_flash
        SetFlashMatcher.new.in_context(self)
      end

      # @private
      class SetFlashMatcher
        extend Forwardable

        def_delegators :underlying_matcher,
          :description,
          :matches?,
          :failure_message,
          :failure_message_when_negated
        alias_method \
          :failure_message_for_should,
          :failure_message
        alias_method \
          :failure_message_for_should_not,
          :failure_message_when_negated

        def initialize
          store = FlashStore.future
          @underlying_matcher = SetSessionOrFlashMatcher.new(store)
        end

        def now
          store = FlashStore.now
          @underlying_matcher = SetSessionOrFlashMatcher.new(store)
          self
        end

        def in_context(context)
          underlying_matcher.in_context(context)
          self
        end

        def [](key)
          underlying_matcher[key]
          self
        end

        def to(expected_value = nil, &block)
          underlying_matcher.to(expected_value, &block)
          self
        end

        protected

        attr_reader :underlying_matcher
      end
    end
  end
end
