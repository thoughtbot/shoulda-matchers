module Shoulda
  module Matchers
    module ActionController
      # The `render_template` matcher tests that an action renders a template
      # or partial. In RSpec, it is very similar to rspec-rails's
      # `render_template` matcher. In Test::Unit, it provides a more expressive
      # syntax over `assert_template`.
      #
      #     class PostsController < ApplicationController
      #       def show
      #       end
      #     end
      #
      #     # app/views/posts/show.html.erb
      #     <%= render 'sidebar' %>
      #
      #     # RSpec
      #     describe PostsController do
      #       describe 'GET #show' do
      #         before { get :show }
      #
      #         it { should render_template('show') }
      #         it { should render_template(partial: 'sidebar') }
      #       end
      #     end
      #
      #     # Test::Unit
      #     class PostsControllerTest < ActionController::TestCase
      #       context 'GET #show' do
      #         setup { get :show }
      #
      #         should render_template('show')
      #         should render_template(partial: 'sidebar')
      #       end
      #     end
      #
      # 
      #
      # @return [RenderTemplateMatcher]
      #
      def render_template(options = {}, message = nil)
        RenderTemplateMatcher.new(options, message, self)
      end

      # @private
      class RenderTemplateMatcher
        attr_reader :failure_message, :failure_message_when_negated

        alias failure_message_for_should failure_message
        alias failure_message_for_should_not failure_message_when_negated

        def initialize(options, message, context)
          @options = options
          @message = message
          @template = options.is_a?(Hash) ? options[:partial] : options
          @context = context
          @controller = nil
          @failure_message = nil
          @failure_message_when_negated = nil
        end

        def matches?(controller)
          @controller = controller
          renders_template?
        end

        def description
          "render template #{@template}"
        end

        def in_context(context)
          @context = context
          self
        end

        private

        def renders_template?
          begin
            @context.__send__(:assert_template, @options, @message)
            @failure_message_when_negated = "Didn't expect to render #{@template}"
            true
          rescue Shoulda::Matchers::AssertionError => error
            @failure_message = error.message
            false
          end
        end
      end
    end
  end
end
