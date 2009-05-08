module Shoulda # :nodoc:
  module ActionView # :nodoc:
    # = Macro test helpers for your view
    #
    # By using the macro helpers you can quickly and easily create concise and
    # easy to read test suites.
    #
    # This code segment:
    #   context "on GET to :new" do
    #     setup do
    #       get :new
    #     end
    #
    #     should_render_page_with_metadata :title => /index/
    #
    #     should "do something else really cool" do
    #       assert_select '#really_cool'
    #     end
    #   end
    #
    # Would produce 3 tests for the +show+ action
    module Macros

      # Macro that creates a test asserting that the rendered view contains a <form> element.
      #
      # Deprecated.
      def should_render_a_form
        warn "[DEPRECATION] should_render_a_form is deprecated."
        should "display a form" do
          assert_select "form", true, "The template doesn't contain a <form> element"
        end
      end

      # Deprecated.
      #
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
        warn "[DEPRECATION] should_render_page_with_metadata is deprecated."
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
    end
  end
end

