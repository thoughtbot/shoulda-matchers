module Shoulda # :nodoc:
  module Controller # :nodoc:
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

      # :section: Test macros
      # Macro that creates a test asserting that the flash contains the given value.
      # val can be a String, a Regex, or nil (indicating that the flash should not be set)
      #
      # Example:
      #
      #   should_set_the_flash_to "Thank you for placing this order."
      #   should_set_the_flash_to /created/i
      #   should_set_the_flash_to nil
      def should_set_the_flash_to(val)
        matcher = set_the_flash.to(val)
        if val
          should matcher.description do
            assert_accepts matcher, @controller
          end
        else
          should "not #{matcher.description}" do
            assert_rejects matcher, @controller
          end
        end
      end

      # Macro that creates a test asserting that the flash is empty.  Same as
      # @should_set_the_flash_to nil@
      def should_not_set_the_flash
        should_set_the_flash_to nil
      end

      # Macro that creates a test asserting that filter_parameter_logging
      # is set for the specified keys
      #
      # Example:
      #
      #   should_filter_params :password, :ssn
      def should_filter_params(*keys)
        keys.each do |key|
          matcher = filter_param(key)
          should matcher.description do
            assert_accepts matcher, @controller
          end
        end
      end

      # Macro that creates a test asserting that the controller assigned to
      # each of the named instance variable(s).
      #
      # Options:
      # * <tt>:class</tt> - The expected class of the instance variable being checked.
      # * <tt>:equals</tt> - A string which is evaluated and compared for equality with
      # the instance variable being checked.
      #
      # Example:
      #
      #   should_assign_to :user, :posts
      #   should_assign_to :user, :class => User
      #   should_assign_to(:user) { @user }
      def should_assign_to(*names, &block)
        opts = names.extract_options!
        if opts[:equals]
          warn "[DEPRECATION] should_assign_to :var, :equals => 'val' " <<
               "is deprecated. Use should_assign_to(:var) { 'val' } instead."
        end
        names.each do |name|
          matcher = assign_to(name).with_kind_of(opts[:class])
          test_name = matcher.description
          test_name << " which is equal to #{opts[:equals]}" if opts[:equals]
          should test_name do
            if opts[:equals]
              instantiate_variables_from_assigns do
                expected_value = eval(opts[:equals],
                                      self.send(:binding),
                                      __FILE__,
                                      __LINE__)
                matcher = matcher.with(expected_value)
              end
            elsif block
              expected_value = instance_eval(&block)
              matcher = matcher.with(expected_value)
            end

            assert_accepts matcher, @controller
          end
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
          matcher = assign_to(name)
          should "not #{matcher.description}" do
            assert_rejects matcher, @controller
          end
        end
      end

      # Macro that creates a test asserting that the controller responded with a 'response' status code.
      # Example:
      #
      #   should_respond_with :success
      def should_respond_with(response)
        should "respond with #{response}" do
          matcher = respond_with(response)
          assert_accepts matcher, @controller
        end
      end

      # Macro that creates a test asserting that the response content type was 'content_type'.
      # Example:
      #
      #   should_respond_with_content_type 'application/rss+xml'
      #   should_respond_with_content_type :rss
      #   should_respond_with_content_type /rss/
      def should_respond_with_content_type(content_type)
        should "respond with content type of #{content_type}" do
          matcher = respond_with_content_type(content_type)
          assert_accepts matcher, @controller
        end
      end

      # Macro that creates a test asserting that a value returned from the session is correct.
      # The given string is evaled to produce the resulting redirect path.  All of the instance variables
      # set by the controller are available to the evaled string.
      # Example:
      #
      #   should_return_from_session :user_id, '@user.id'
      #   should_return_from_session :message, '"Free stuff"'
      def should_return_from_session(key, expected)
        matcher = set_session(key)
        should matcher.description do
          instantiate_variables_from_assigns do
            expected_value = eval(expected, 
                                  self.send(:binding),
                                  __FILE__,
                                  __LINE__)
            matcher = matcher.to(expected_value)
            assert_accepts matcher, @controller
          end
        end
      end

      # Macro that creates a test asserting that the controller rendered the given template.
      # Example:
      #
      #   should_render_template :new
      def should_render_template(template)
        should "render template #{template.inspect}" do
          assert_template template.to_s
        end
      end

      # Macro that creates a test asserting that the controller rendered with the given layout.
      # Example:
      #
      #   should_render_with_layout 'special'
      def should_render_with_layout(expected_layout = 'application')
        matcher = render_with_layout(expected_layout)
        if expected_layout
          should matcher.description do
            assert_accepts matcher, @controller
          end
        else
          should "render without layout" do
            assert_rejects matcher, @controller
          end
        end
      end

      # Macro that creates a test asserting that the controller rendered without a layout.
      # Same as @should_render_with_layout false@
      def should_render_without_layout
        should_render_with_layout nil
      end

      # Macro that creates a test asserting that the controller returned a redirect to the given path.
      # The given string is evaled to produce the resulting redirect path.  All of the instance variables
      # set by the controller are available to the evaled string.
      # Example:
      #
      #   should_redirect_to '"/"'
      #   should_redirect_to "user_url(@user)"
      #   should_redirect_to "users_url"
      def should_redirect_to(url)
        should "redirect to #{url.inspect}" do
          instantiate_variables_from_assigns do
            assert_redirected_to eval(url, self.send(:binding), __FILE__, __LINE__)
          end
        end
      end

      # Macro that creates a test asserting that the rendered view contains a <form> element.
      def should_render_a_form
        should "display a form" do
          assert_select "form", true, "The template doesn't contain a <form> element"
        end
      end

      # Macro that creates a test asserting that the rendered view contains the selected metatags.
      # Values can be string or Regexps.
      # Example:
      #
      #   should_render_page_with_metadata :description => "Description of this page", :keywords => /post/
      #
      # You can also use this method to test the rendered views title.
      #
      # Example:
      #   should_render_page_with_metadata :title => /index/
      def should_render_page_with_metadata(options)
        options.each do |key, value|
          should "have metatag #{key}" do
            if key.to_sym == :title
              assert_select "title", value
            else
              assert_select "meta[name=?][content#{"*" if value.is_a?(Regexp)}=?]", key, value
            end
          end
        end
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
        unless options[:controller]
          options[:controller] = self.name.gsub(/ControllerTest$/, '').tableize
        end

        matcher = route(method, path).to(options)

        should matcher.description do
          assert_accepts matcher.in_context(self), self
        end
      end
    end
  end
end
