module Shoulda
  module Matchers
    module ActionController
      # The `use_before_filter` matcher is used to test that a before_filter
      # callback is defined within your controller.
      #
      #     class UsersController < ApplicationController
      #       before_filter :authenticate_user!
      #     end
      #
      #     # RSpec
      #     describe UsersController do
      #       it { should use_before_filter(:authenticate_user!) }
      #       it { should_not use_before_filter(:prevent_ssl) }
      #     end
      #
      #     # Test::Unit
      #     class UsersControllerTest < ActionController::TestCase
      #       should use_before_filter(:authenticate_user!)
      #       should_not use_before_filter(:prevent_ssl)
      #     end
      #
      # #### Qualifiers
      #
      # ##### only
      #
      # Use `only` to assert that the filter acts on specific actions.
      #
      #     class UsersController < ApplicationController
      #       before_filter :authenticate_user!, only: :edit
      #     end
      #
      #     # RSpec
      #     describe UsersController do
      #       it { should use_before_filter(:authenticate_user!).only(:edit) }
      #     end
      #
      #     # Test::Unit
      #     class UsersControllerTest < ActionController::TestCase
      #       should use_before_filter(:authenticate_user!).only(:edit)
      #     end
      #
      # ##### except
      #
      # Use `except` to assert that the filter acts on specific actions.
      #
      #     class UsersController < ApplicationController
      #       before_filter :authenticate_user!, except: :show
      #     end
      #
      #     # RSpec
      #     describe UsersController do
      #       it { should use_before_filter(:authenticate_user!).except(:show) }
      #     end
      #
      #     # Test::Unit
      #     class UsersControllerTest < ActionController::TestCase
      #       should use_before_filter(:authenticate_user!).except(:show)
      #     end
      # @return [CallbackMatcher]
      #
      def use_before_filter(callback)
        CallbackMatcher.new(callback, :before, :filter)
      end

      # The `use_after_filter` matcher is used to test that an after_filter
      # callback is defined within your controller.
      #
      #     class IssuesController < ApplicationController
      #       after_filter :log_activity
      #     end
      #
      #     # RSpec
      #     describe IssuesController do
      #       it { should use_after_filter(:log_activity) }
      #       it { should_not use_after_filter(:destroy_user) }
      #     end
      #
      #     # Test::Unit
      #     class IssuesControllerTest < ActionController::TestCase
      #       should use_after_filter(:log_activity)
      #       should_not use_after_filter(:destroy_user)
      #     end
      #
      # #### Qualifiers
      #
      # ##### only
      #
      # Use `only` to assert that the filter acts on specific actions.
      #
      #     class UsersController < ApplicationController
      #       after_filter :log_activity, only: :edit
      #     end
      #
      #     # RSpec
      #     describe UsersController do
      #       it { should use_after_filter(:log_activity).only(:edit) }
      #     end
      #
      #     # Test::Unit
      #     class UsersControllerTest < ActionController::TestCase
      #       should use_after_filter(:log_activity).only(:edit)
      #     end
      #
      # ##### except
      #
      # Use `except` to assert that the filter acts on specific actions.
      #
      #     class UsersController < ApplicationController
      #       after_filter :log_activity, except: :show
      #     end
      #
      #     # RSpec
      #     describe UsersController do
      #       it { should use_after_filter(:log_activity).except(:show) }
      #     end
      #
      #     # Test::Unit
      #     class UsersControllerTest < ActionController::TestCase
      #       should use_after_filter(:log_activity).except(:show)
      #     end
      # @return [CallbackMatcher]
      #
      def use_after_filter(callback)
        CallbackMatcher.new(callback, :after, :filter)
      end

      # The `use_before_action` matcher is used to test that a before_action
      # callback is defined within your controller.
      #
      #     class UsersController < ApplicationController
      #       before_action :authenticate_user!
      #     end
      #
      #     # RSpec
      #     describe UsersController do
      #       it { should use_before_action(:authenticate_user!) }
      #       it { should_not use_before_action(:prevent_ssl) }
      #     end
      #
      #     # Test::Unit
      #     class UsersControllerTest < ActionController::TestCase
      #       should use_before_action(:authenticate_user!)
      #       should_not use_before_action(:prevent_ssl)
      #     end
      #
      # #### Qualifiers
      #
      # ##### only
      #
      # Use `only` to assert that the callback acts on specific actions.
      #
      #     class UsersController < ApplicationController
      #       before_action :authenticate_user!, only: :edit
      #     end
      #
      #     # RSpec
      #     describe UsersController do
      #       it { should use_before_action(:authenticate_user!).only(:edit) }
      #     end
      #
      #     # Test::Unit
      #     class UsersControllerTest < ActionController::TestCase
      #       should use_before_action(:authenticate_user!).only(:edit)
      #     end
      #
      # ##### except
      #
      # Use `except` to assert that the callback acts on specific actions.
      #
      #     class UsersController < ApplicationController
      #       before_action :authenticate_user!, except: :show
      #     end
      #
      #     # RSpec
      #     describe UsersController do
      #       it { should use_before_action(:authenticate_user!).except(:show) }
      #     end
      #
      #     # Test::Unit
      #     class UsersControllerTest < ActionController::TestCase
      #       should use_before_action(:authenticate_user!).except(:show)
      #     end
      # @return [CallbackMatcher]
      #
      def use_before_action(callback)
        CallbackMatcher.new(callback, :before, :action)
      end

      # The `use_after_action` matcher is used to test that an after_action
      # callback is defined within your controller.
      #
      #     class IssuesController < ApplicationController
      #       after_action :log_activity
      #     end
      #
      #     # RSpec
      #     describe IssuesController do
      #       it { should use_after_action(:log_activity) }
      #       it { should_not use_after_action(:destroy_user) }
      #     end
      #
      #     # Test::Unit
      #     class IssuesControllerTest < ActionController::TestCase
      #       should use_after_action(:log_activity)
      #       should_not use_after_action(:destroy_user)
      #     end
      #
      # #### Qualifiers
      #
      # ##### only
      #
      # Use `only` to assert that the callback acts on specific actions.
      #
      #     class UsersController < ApplicationController
      #
      #       after_action :log_activity, only: :edit
      #     end
      #
      #     # RSpec
      #     describe UsersController do
      #       it { should use_after_action(:log_activity).only(:edit) }
      #     end
      #
      #     # Test::Unit
      #     class UsersControllerTest < ActionController::TestCase
      #       should use_after_action(:log_activity).only(:edit)
      #     end
      #
      # ##### except
      #
      # Use `except` to assert that the callback acts on specific actions.
      #
      #     class UsersController < ApplicationController
      #
      #       after_action :log_activity, except: :show
      #     end
      #
      #     # RSpec
      #     describe UsersController do
      #       it { should use_after_action(:log_activity).except(:show) }
      #     end
      #
      #     # Test::Unit
      #     class UsersControllerTest < ActionController::TestCase
      #       should use_after_action(:log_activity).except(:show)
      #     end
      #
      # @return [CallbackMatcher]
      #
      def use_after_action(callback)
        CallbackMatcher.new(callback, :after, :action)
      end

      # The `use_around_filter` matcher is used to test that an around_filter
      # callback is defined within your controller.
      #
      #     class ChangesController < ApplicationController
      #       around_filter :wrap_in_transaction
      #     end
      #
      #     # RSpec
      #     describe ChangesController do
      #       it { should use_around_filter(:wrap_in_transaction) }
      #       it { should_not use_around_filter(:save_view_context) }
      #     end
      #
      #     # Test::Unit
      #     class ChangesControllerTest < ActionController::TestCase
      #       should use_around_filter(:wrap_in_transaction)
      #       should_not use_around_filter(:save_view_context)
      #     end
      #
      # #### Qualifiers
      #
      # ##### only
      #
      # Use `only` to assert that the filter acts on specific actions.
      #
      #     class ChangesController < ApplicationController
      #       around_filter :wrap_in_transaction, only: :edit
      #     end
      #
      #     # RSpec
      #     describe ChangesController do
      #       it { should use_around_filter(:wrap_in_transaction).only(:edit) }
      #     end
      #
      #     # Test::Unit
      #     class ChangesControllerTest < ActionController::TestCase
      #       should use_around_filter(:wrap_in_transaction).only(:edit)
      #     end
      #
      # ##### except
      #
      # Use `except` to assert that the filter acts on specific actions.
      #
      #     class ChangesController < ApplicationController
      #       around_filter :wrap_in_transaction, except: :show
      #     end
      #
      #     # RSpec
      #     describe ChangesController do
      #       it { should use_around_filter(:wrap_in_transaction).except(:show) }
      #     end
      #
      #     # Test::Unit
      #     class ChangesControllerTest < ActionController::TestCase
      #       should use_around_filter(:wrap_in_transaction).except(:show)
      #     end
      #
      # @return [CallbackMatcher]
      #
      def use_around_filter(callback)
        CallbackMatcher.new(callback, :around, :filter)
      end

      # The `use_around_action` matcher is used to test that an around_action
      # callback is defined within your controller.
      #
      #     class ChangesController < ApplicationController
      #       around_action :wrap_in_transaction
      #     end
      #
      #     # RSpec
      #     describe ChangesController do
      #       it { should use_around_action(:wrap_in_transaction) }
      #       it { should_not use_around_action(:save_view_context) }
      #     end
      #
      #     # Test::Unit
      #     class ChangesControllerTest < ActionController::TestCase
      #       should use_around_action(:wrap_in_transaction)
      #       should_not use_around_action(:save_view_context)
      #     end
      #
      # #### Qualifiers
      #
      # ##### only
      #
      # Use `only` to assert that the callback acts on specific actions.
      #
      #     class ChangesController < ApplicationController
      #       around_action :wrap_in_transaction, only: :edit
      #     end
      #
      #     # RSpec
      #     describe ChangesController do
      #       it { should use_around_action(:wrap_in_transaction).only(:edit) }
      #     end
      #
      #     # Test::Unit
      #     class ChangesControllerTest < ActionController::TestCase
      #       should use_around_action(:wrap_in_transaction).only(:edit)
      #     end
      #
      # ##### except
      #
      # Use `except` to assert that the callback acts on specific actions.
      #
      #     class ChangesController < ApplicationController
      #       around_action :wrap_in_transaction, except: :show
      #     end
      #
      #     # RSpec
      #     describe ChangesController do
      #       it { should use_around_action(:wrap_in_transaction).except(:show) }
      #     end
      #
      #     # Test::Unit
      #     class ChangesControllerTest < ActionController::TestCase
      #       should use_around_action(:wrap_in_transaction).except(:show)
      #     end
      #
      # @return [CallbackMatcher]
      #
      def use_around_action(callback)
        CallbackMatcher.new(callback, :around, :action)
      end

      # @private
      class CallbackMatcher
        def initialize(method_name, kind, callback_type)
          @method_name = method_name
          @kind = kind
          @callback_type = callback_type
          @options = {}
        end

        def only(actions)
          @options[:only] = Array(actions)
          self
        end

        def except(actions)
          @options[:except] = Array(actions)
          self
        end

        def matches?(controller)
          @controller = controller
          @controller_class = controller.class

          filter_matches? && only_matches? && except_matches?
        end

        def failure_message
          "Expected that #{controller_class.name} would #{expectation}"
        end
        alias failure_message_for_should failure_message

        def failure_message_when_negated
          "Expected that #{controller_class.name} would not #{expectation}"
        end
        alias failure_message_for_should_not failure_message_when_negated

        def description
          expectation
        end

        protected

        def callbacks
          controller_class._process_action_callbacks.select do |callback|
            callback.kind == kind
          end
        end

        def filter_matches?
          callbacks.map(&:filter).include?(method_name)
        end

        def only_matches?
          conditional_matches?(:only)
        end

        def except_matches?
          conditional_matches?(:except)
        end

        def conditional_matches?(conditional)
          if options.key?(conditional)
            callbacks.any? do |c|
              c.filter == method_name &&
                conditional_callback(c, conditional) == conditional_options(conditional)
            end
          else
            true
          end
        end

        def conditional_callback(callback, conditional)
          key = conditional == :except ? :unless : :if
          if RailsShim.action_pack_gte_4_1?
            callback.instance_variable_get(:"@#{key}").first
          else
            callback.options[key].first
          end
        end

        def conditional_options(conditional)
          options[conditional].map do |action|
            "action_name == '#{action}'"
          end.join(' || ')
        end

        def expectation
          message = "have :#{method_name} as a #{kind}_#{callback_type}"
          if options.key?(:only)
            message << " :only => #{options[:only]}"
          end
          if options.key?(:except)
            message << " :except => #{options[:except]}"
          end
          message
        end

        attr_reader :method_name, :controller, :controller_class, :kind,
          :callback_type, :options
      end
    end
  end
end
