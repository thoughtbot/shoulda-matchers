require 'shoulda/private_helpers'

module Shoulda # :nodoc:
  module Macros
    # Macro that creates a test asserting a change between the return value
    # of a block that is run before and after the current setup block
    # is run. This is similar to Active Support's <tt>assert_difference</tt>
    # assertion, but supports more than just numeric values.  See also
    # should_not_change.
    #
    # The passed description will be used when generating the test name and failure messages.
    #
    # Example:
    #
    #   context "Creating a post" do
    #     setup { Post.create }
    #     should_change("the number of posts", :by => 1) { Post.count }
    #   end
    #
    # As shown in this example, the <tt>:by</tt> option expects a numeric
    # difference between the before and after values of the expression.  You
    # may also specify <tt>:from</tt> and <tt>:to</tt> options:
    #
    #   should_change("the number of posts", :from => 0, :to => 1) { Post.count }
    #   should_change("the post title", :from => "old", :to => "new") { @post.title }
    #
    # Combinations of <tt>:by</tt>, <tt>:from</tt>, and <tt>:to</tt> are allowed:
    #
    #   # Assert the value changed in some way:
    #   should_change("the post title") { @post.title }
    #
    #   # Assert the value changed to anything other than "old:"
    #   should_change("the post title", :from => "old") { @post.title }
    #
    #   # Assert the value changed to "new:"
    #   should_change("the post title", :to => "new") { @post.title }
    def should_change(description, options = {}, &block)
      by, from, to = get_options!([options], :by, :from, :to)
      stmt = "change #{description}"
      stmt << " from #{from.inspect}" if from
      stmt << " to #{to.inspect}" if to
      stmt << " by #{by.inspect}" if by

      if block_given?
        code = block
      else
        warn "[DEPRECATION] should_change(expression, options) is deprecated. " <<
             "Use should_change(description, options) { code } instead."
        code = lambda { eval(description) }
      end
      before = lambda { @_before_should_change = code.bind(self).call }
      should stmt, :before => before do
        old_value = @_before_should_change
        new_value = code.bind(self).call
        assert_operator from, :===, old_value, "#{description} did not originally match #{from.inspect}" if from
        assert_not_equal old_value, new_value, "#{description} did not change" unless by == 0
        assert_operator to, :===, new_value, "#{description} was not changed to match #{to.inspect}" if to
        assert_equal old_value + by, new_value if by
      end
    end

    # Macro that creates a test asserting no change between the return value
    # of a block that is run before and after the current setup block
    # is run. This is the logical opposite of should_change.
    #
    # The passed description will be used when generating the test name and failure message.
    #
    # Example:
    #
    #   context "Updating a post" do
    #     setup { @post.update_attributes(:title => "new") }
    #     should_not_change("the number of posts") { Post.count }
    #   end
    def should_not_change(description, &block)
      if block_given?
        code = block
      else
        warn "[DEPRECATION] should_not_change(expression) is deprecated. " <<
             "Use should_not_change(description) { code } instead."
        code = lambda { eval(description) }
      end
      before = lambda { @_before_should_not_change = code.bind(self).call }
      should "not change #{description}", :before => before do
        new_value = code.bind(self).call
        assert_equal @_before_should_not_change, new_value, "#{description} changed"
      end
    end

    # Macro that creates a test asserting that a record of the given class was
    # created.
    #
    # Example:
    #
    #   context "creating a post" do
    #     setup { Post.create(post_attributes) }
    #     should_create :post
    #   end
    def should_create(class_name)
      should_change_record_count_of(class_name, 1, 'create')
    end

    # Macro that creates a test asserting that a record of the given class was
    # destroyed.
    #
    # Example:
    #
    #   context "destroying a post" do
    #     setup { Post.first.destroy }
    #     should_destroy :post
    #   end
    def should_destroy(class_name)
      should_change_record_count_of(class_name, -1, 'destroy')
    end

    private

    def should_change_record_count_of(class_name, amount, action) # :nodoc:
      klass = class_name.to_s.camelize.constantize
      before = lambda do
        @_before_change_record_count = klass.count
      end
      human_name = class_name.to_s.humanize.downcase
      should "#{action} a #{human_name}", :before => before do
        assert_equal @_before_change_record_count + amount,
                     klass.count,
                     "Expected to #{action} a #{human_name}"
      end
    end

    include Shoulda::Private
  end
end

