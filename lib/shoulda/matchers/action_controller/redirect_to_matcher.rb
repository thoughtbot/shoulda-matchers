module Shoulda
  module Matchers
    module ActionController
      # The `redirect_to` matcher tests that an action redirects to a certain
      # location. In a test suite using RSpec, it is very similar to
      # rspec-rails's `redirect_to` matcher. In a test suite using Test::Unit /
      # Shoulda, it provides a more expressive syntax over
      # `assert_redirected_to`.
      #
      #     class PostsController < ApplicationController
      #       def show
      #         redirect_to :index
      #       end
      #     end
      #
      #     # RSpec
      #     describe PostsController do
      #       describe 'GET #show' do
      #         before { get :show }
      #
      #         it { should redirect_to(posts_path) }
      #         it { should redirect_to(action: :index) }
      #       end
      #     end
      #
      #     # Test::Unit
      #     class PostsControllerTest < ActionController::TestCase
      #       context 'GET #show' do
      #         setup { get :show }
      #
      #         should redirect_to { posts_path }
      #         should redirect_to(action: :index)
      #       end
      #     end
      #
      # @return [RedirectToMatcher]
      #
      def redirect_to(url_or_description, &block)
        RedirectToMatcher.new(url_or_description, self, &block)
      end

      # @private
      class RedirectToMatcher
        attr_reader :failure_message, :failure_message_when_negated

        alias failure_message_for_should failure_message
        alias failure_message_for_should_not failure_message_when_negated

        def initialize(url_or_description, context, &block)
          @url_block = nil
          @url = nil
          @context = context
          @failure_message = nil
          @failure_message_when_negated = nil

          if block
            @url_block = block
            @location = url_or_description
          else
            @location = @url = url_or_description
          end
        end

        def in_context(context)
          @context = context
          self
        end

        def matches?(controller)
          @controller = controller
          redirects_to_url?
        end

        def description
          "redirect to #{@location.inspect}"
        end

        private

        def redirects_to_url?
          begin
            @context.__send__(:assert_redirected_to, url)
            @failure_message_when_negated = "Didn't expect to redirect to #{url}"
            true
          rescue Shoulda::Matchers::AssertionError => error
            @failure_message = error.message
            false
          end
        end

        def url
          if @url_block
            @context.instance_eval(&@url_block)
          else
            @url
          end
        end
      end
    end
  end
end
