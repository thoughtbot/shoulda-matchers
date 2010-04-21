module Shoulda # :nodoc:
  module ActionController # :nodoc:
    # = Macro test helpers for your controllers
    #
    # By using the macro helpers you can quickly and easily create concise and easy to read test suites.
    #
    # This code segment:
    #   context "on GET to :show for first record" do
    #     setup do
    #       get :show, :id => 1
    #     end
    #
    #     should_assign_to :user
    #     should_respond_with :success
    #     should_render_template :show
    #     should_not_set_the_flash
    #
    #     should "do something else really cool" do
    #       assert_equal 1, assigns(:user).id
    #     end
    #   end
    #
    # Would produce 5 tests for the +show+ action
    module Macros
      include Matchers

      # Macro that creates a test asserting that the flash contains the given
      # value. Expects a +String+ or +Regexp+.
      #
      # Example:
      #
      #   should_set_the_flash_to "Thank you for placing this order."
      #   should_set_the_flash_to /created/i
      def should_set_the_flash_to(val)
        should set_the_flash.to(val)
      end

      # Macro that creates a test asserting that the flash is empty.
      def should_not_set_the_flash
        should_not set_the_flash
      end

      # Macro that creates a test asserting that filter_parameter_logging
      # is set for the specified keys
      #
      # Example:
      #
      #   should_filter_params :password, :ssn
      def should_filter_params(*keys)
        keys.each do |key|
          should filter_param(key)
        end
      end

      # Macro that creates a test asserting that the controller assigned to
      # each of the named instance variable(s).
      #
      # Options:
      # * <tt>:class</tt> - The expected class of the instance variable being checked.
      #
      # If a block is passed, the assigned variable is expected to be equal to
      # the return value of that block.
      #
      # Example:
      #
      #   should_assign_to :user, :posts
      #   should_assign_to :user, :class => User
      #   should_assign_to(:user) { @user }
      def should_assign_to(*names, &block)
        klass = get_options!(names, :class)
        names.each do |name|
          matcher = assign_to(name).with_kind_of(klass)
          matcher = matcher.with(&block) if block
          should matcher
        end
      end

      # Macro that creates a test asserting that the controller did not assign to
      # any of the named instance variable(s).
      #
      # Example:
      #
      #   should_not_assign_to :user, :posts
      def should_not_assign_to(*names)
        names.each do |name|
          should_not assign_to(name)
        end
      end

      # Macro that creates a test asserting that the controller responded with a 'response' status code.
      # Example:
      #
      #   should_respond_with :success
      def should_respond_with(response)
        should respond_with(response)
      end

      # Macro that creates a test asserting that the response content type was 'content_type'.
      # Example:
      #
      #   should_respond_with_content_type 'application/rss+xml'
      #   should_respond_with_content_type :rss
      #   should_respond_with_content_type /rss/
      def should_respond_with_content_type(content_type)
        should respond_with_content_type(content_type)
      end

      # Macro that creates a test asserting that a value returned from the
      # session is correct. Expects the session key as a parameter, and a block
      # that returns the expected value.
      #
      # Example:
      #
      #   should_set_session(:user_id) { @user.id }
      #   should_set_session(:message) { "Free stuff" }
      def should_set_session(key, &block)
        matcher = set_session(key)
        matcher = matcher.to(&block) if block
        should matcher
      end

      # Macro that creates a test asserting that the controller rendered the given template.
      # Example:
      #
      #   should_render_template :new
      def should_render_template(template)
        should render_template(template)
      end

      # Macro that creates a test asserting that the controller rendered with the given layout.
      # Example:
      #
      #   should_render_with_layout 'special'
      def should_render_with_layout(expected_layout = 'application')
        should render_with_layout(expected_layout)
      end

      # Macro that creates a test asserting that the controller rendered without a layout.
      # Same as @should_render_with_layout false@
      def should_render_without_layout
        should_not render_with_layout
      end

      # Macro that creates a test asserting that the controller returned a
      # redirect to the given path. The passed description will be used when
      # generating a test name. Expects a block that returns the expected path
      # for the redirect.
      #
      # Example:
      #
      #   should_redirect_to("the user's profile") { user_url(@user) }
      def should_redirect_to(description, &block)
        should redirect_to(description, &block)
      end

      # Macro that creates a routing test. It tries to use the given HTTP
      # +method+ on the given +path+, and asserts that it routes to the
      # given +options+.
      #
      # If you don't specify a :controller, it will try to guess the controller
      # based on the current test.
      #
      # +to_param+ is called on the +options+ given.
      #
      # Examples:
      #
      #   should_route :get, "/posts", :controller => :posts, :action => :index
      #   should_route :get, "/posts/new", :action => :new
      #   should_route :post, "/posts", :action => :create
      #   should_route :get, "/posts/1", :action => :show, :id => 1
      #   should_route :edit, "/posts/1", :action => :show, :id => 1
      #   should_route :put, "/posts/1", :action => :update, :id => 1
      #   should_route :delete, "/posts/1", :action => :destroy, :id => 1
      #   should_route :get, "/users/1/posts/1",
      #     :action => :show, :id => 1, :user_id => 1
      #
      def should_route(method, path, options)
        should route(method, path).to(options)
      end
    end
  end
end
