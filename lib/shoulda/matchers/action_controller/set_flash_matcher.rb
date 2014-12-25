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
        SetFlashMatcher.new
      end

      # @deprecated Use {#set_flash} instead.
      # @return [SetFlashMatcher]
      def set_the_flash
        Shoulda::Matchers.warn_about_deprecated_method(
          :set_the_flash,
          :set_flash
        )
        set_flash
      end

      # @private
      class SetFlashMatcher
        def initialize
          @options = {}
          @value = nil
        end

        def to(value)
          if !value.is_a?(String) && !value.is_a?(Regexp)
            raise "cannot match against #{value.inspect}"
          end
          @value = value
          self
        end

        def now
          @options[:now] = true
          self
        end

        def [](key)
          @options[:key] = key
          self
        end

        def matches?(controller)
          @controller = controller
          sets_the_flash? && string_value_matches? && regexp_value_matches?
        end

        def description
          description = "set the #{expected_flash_invocation}"
          description << " to #{@value.inspect}" unless @value.nil?
          description
        end

        def failure_message
          "Expected #{expectation}"
        end
        alias failure_message_for_should failure_message

        def failure_message_when_negated
          "Did not expect #{expectation}"
        end
        alias failure_message_for_should_not failure_message_when_negated

        private

        def sets_the_flash?
          flash_values.any?
        end

        def string_value_matches?
          if @value.is_a?(String)
            flash_values.any? {|value| value == @value }
          else
            true
          end
        end

        def regexp_value_matches?
          if @value.is_a?(Regexp)
            flash_values.any? {|value| value =~ @value }
          else
            true
          end
        end

        def flash_values
          if @options.key?(:key)
            flash_hash = HashWithIndifferentAccess.new(flash.to_hash)
            [flash_hash[@options[:key]]]
          else
            flash.to_hash.values
          end
        end

        def flash
          @flash ||= copy_of_flash_from_controller
        end

        def copy_of_flash_from_controller
          @controller.flash.dup.tap do |flash|
            copy_flashes(@controller.flash, flash)
            copy_discard_if_necessary(@controller.flash, flash)
            sweep_flash_if_necessary(flash)
          end
        end

        def copy_flashes(original_flash, new_flash)
          flashes_ivar = Shoulda::Matchers::RailsShim.flashes_ivar
          flashes = original_flash.instance_variable_get(flashes_ivar).dup
          new_flash.instance_variable_set(flashes_ivar, flashes)
        end

        def copy_discard_if_necessary(original_flash, new_flash)
          discard_ivar = :@discard
          if original_flash.instance_variable_defined?(discard_ivar)
            discard = original_flash.instance_variable_get(discard_ivar).dup
            new_flash.instance_variable_set(discard_ivar, discard)
          end
        end

        def sweep_flash_if_necessary(flash)
          unless @options[:now]
            flash.sweep
          end
        end

        def expectation
          expectation = "the #{expected_flash_invocation} to be set"
          expectation << " to #{@value.inspect}" unless @value.nil?
          expectation << ", but #{flash_description}"
          expectation
        end

        def flash_description
          if flash.blank?
            'no flash was set'
          else
            "was #{flash.inspect}"
          end
        end

        def expected_flash_invocation
          "flash#{pretty_now}#{pretty_key}"
        end

        def pretty_now
          if @options[:now]
            '.now'
          else
            ''
          end
        end

        def pretty_key
          if @options[:key]
            "[:#{@options[:key]}]"
          else
            ''
          end
        end
      end
    end
  end
end
