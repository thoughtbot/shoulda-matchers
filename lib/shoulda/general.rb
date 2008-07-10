module ThoughtBot # :nodoc:
  module Shoulda # :nodoc:
    module General
      def self.included(other) # :nodoc:
        other.class_eval do
          extend ThoughtBot::Shoulda::General::ClassMethods
        end
      end
      
      module ClassMethods
        # Loads all fixture files (<tt>test/fixtures/*.yml</tt>)
        def load_all_fixtures
          all_fixtures = Dir.glob(File.join(Test::Unit::TestCase.fixture_path, "*.yml")).collect do |f| 
            File.basename(f, '.yml').to_sym
          end
          fixtures *all_fixtures
        end
        
        # Macro that creates a test asserting a change between the return value
        # of an expression that is run before and after the current setup block
        # is run. This is similar to Active Support's <tt>assert_difference</tt>
        # assertion, but supports more than just numeric values.  See also
        # should_not_change.
        #
        # Example:
        #
        #   context "Creating a post"
        #     setup do
        #       Post.create
        #     end
        #
        #     should_change "Post.count", :by => 1
        #   end
        #
        # As shown in this example, the <tt>:by</tt> option expects a numeric
        # difference between the before and after values of the expression.  You
        # may also specify <tt>:from</tt> and <tt>:to</tt> options:
        #
        #   should_change "Post.count", :from => 0, :to => 1
        #   should_change "@post.title", :from => "old", :to => "new"
        #
        # Combinations of <tt>:by</tt>, <tt>:from</tt>, and <tt>:to</tt> are allowed:
        #
        #   should_change "@post.title"                # => assert the value changed in some way
        #   should_change "@post.title" :from => "old" # => assert the value changed to anything other than "old"
        #   should_change "@post.title" :to   => "new" # => assert the value changed from anything other than "new"
        def should_change(expression, options = {}) 
          by, from, to = get_options!([options], :by, :from, :to)
          stmt = "change #{expression.inspect}"
          stmt << " from #{from.inspect}" if from
          stmt << " to #{to.inspect}" if to
          stmt << " by #{by.inspect}" if by

          expression_eval = lambda { eval(expression) }
          before = lambda { @_before_should_change = expression_eval.bind(self).call }
          should stmt, :before => before do
            old_value = @_before_should_change
            new_value = expression_eval.bind(self).call
            assert_operator from, :===, old_value, "#{expression.inspect} did not originally match #{from.inspect}" if from
            assert_not_equal old_value, new_value, "#{expression.inspect} did not change" unless by == 0
            assert_operator to, :===, new_value, "#{expression.inspect} was not changed to match #{to.inspect}" if to
            assert_equal old_value + by, new_value if by
          end
        end
        
        # Macro that creates a test asserting no change between the return value
        # of an expression that is run before and after the current setup block
        # is run. This is the logical opposite of should_change.
        #
        # Example:
        #
        #   context "Updating a post"
        #     setup do
        #       @post.update_attributes(:title => "new")
        #     end
        #
        #     should_not_change "Post.count"
        #   end
        def should_not_change(expression)
          expression_eval = lambda { eval(expression) }
          before = lambda { @_before_should_not_change = expression_eval.bind(self).call }
          should "not change #{expression.inspect}", :before => before do
            new_value = expression_eval.bind(self).call
            assert_equal @_before_should_not_change, new_value, "#{expression.inspect} changed"
          end
        end
      end
      
      # Prints a message to stdout, tagged with the name of the calling method.
      def report!(msg = "")
        puts("#{caller.first}: #{msg}")
      end

      # Asserts that two arrays contain the same elements, the same number of times.  Essentially ==, but unordered.
      #
      #   assert_same_elements([:a, :b, :c], [:c, :a, :b]) => passes
      def assert_same_elements(a1, a2, msg = nil)
        [:select, :inject, :size].each do |m|
          [a1, a2].each {|a| assert_respond_to(a, m, "Are you sure that #{a.inspect} is an array?  It doesn't respond to #{m}.") }
        end

        assert a1h = a1.inject({}) { |h,e| h[e] = a1.select { |i| i == e }.size; h }
        assert a2h = a2.inject({}) { |h,e| h[e] = a2.select { |i| i == e }.size; h }

        assert_equal(a1h, a2h, msg)
      end

      # Asserts that the given collection contains item x.  If x is a regular expression, ensure that
      # at least one element from the collection matches x.  +extra_msg+ is appended to the error message if the assertion fails.
      #
      #   assert_contains(['a', '1'], /\d/) => passes
      #   assert_contains(['a', '1'], 'a') => passes
      #   assert_contains(['a', '1'], /not there/) => fails
      def assert_contains(collection, x, extra_msg = "")
        collection = [collection] unless collection.is_a?(Array)
        msg = "#{x.inspect} not found in #{collection.to_a.inspect} #{extra_msg}"
        case x
        when Regexp: assert(collection.detect { |e| e =~ x }, msg)
        else         assert(collection.include?(x), msg)
        end        
      end

      # Asserts that the given collection does not contain item x.  If x is a regular expression, ensure that
      # none of the elements from the collection match x.
      def assert_does_not_contain(collection, x, extra_msg = "")
        collection = [collection] unless collection.is_a?(Array)
        msg = "#{x.inspect} found in #{collection.to_a.inspect} " + extra_msg
        case x
        when Regexp: assert(!collection.detect { |e| e =~ x }, msg)
        else         assert(!collection.include?(x), msg)
        end        
      end
      
      # Asserts that the given object can be saved
      #
      #  assert_save User.new(params)
      def assert_save(obj)
        assert obj.save, "Errors: #{pretty_error_messages obj}"
        obj.reload
      end

      # Asserts that the given object is valid
      #
      #  assert_valid User.new(params)
      def assert_valid(obj)
        assert obj.valid?, "Errors: #{pretty_error_messages obj}"
      end
      
      # Asserts that an email was delivered.  Can take a block that can further
      # narrow down the types of emails you're expecting. 
      #
      #  assert_sent_email 
      #
      # Passes if ActionMailer::Base.deliveries has an email
      #  
      #  assert_sent_email do |email|
      #    email.subject =~ /hi there/ && email.to.include?('none@none.com')
      #  end
      #  
      # Passes if there is an email with subject containing 'hi there' and
      # 'none@none.com' as one of the recipients.
      #    
      def assert_sent_email
        emails = ActionMailer::Base.deliveries
        assert !emails.empty?, "No emails were sent"
        if block_given?
          matching_emails = emails.select {|email| yield email }
          assert !matching_emails.empty?, "None of the emails matched."
        end
      end

      # Asserts that no ActionMailer mails were delivered
      #
      #  assert_did_not_send_email
      def assert_did_not_send_email
        msg = "Sent #{ActionMailer::Base.deliveries.size} emails.\n"
        ActionMailer::Base.deliveries.each { |m| msg << "  '#{m.subject}' sent to #{m.to.to_sentence}\n" }
        assert ActionMailer::Base.deliveries.empty?, msg
      end

      def pretty_error_messages(obj)
        obj.errors.map { |a, m| "#{a} #{m} (#{obj.send(a).inspect})" }
      end
      
    end
  end
end
