module ThoughtBot # :nodoc:
  module Shoulda # :nodoc:
    # = context and should blocks
    # 
    # A context block can exist next to normal <tt>def test_blah</tt> statements, 
    # meaning you do not have to fully commit to the context/should syntax in a test file.  We have been
    # using this syntax at ThoughtBot, though, and find it very readable.
    #
    # A context block can contain setup, should, should_eventually, and teardown blocks.
    #
    #  class UserTest << Test::Unit 
    #    context "a User instance" do
    #      setup do
    #        @user = User.find(:first)
    #      end
    #    
    #      should "return its full name"
    #        assert_equal 'John Doe', @user.full_name
    #      end
    #    end
    #  end
    #
    # This code will produce the method <tt>"test a User instance should return its full name"</tt> (yes, with spaces in the name).
    #
    # Contexts may be nested.  Nested contexts run their setup blocks from out to in before each test.  
    # They then run their teardown blocks from in to out after each test.
    #
    #  class UserTest << Test::Unit 
    #    context "a User instance" do
    #      setup do
    #        @user = User.find(:first)
    #      end
    #    
    #      should "return its full name"
    #        assert_equal 'John Doe', @user.full_name
    #      end
    #    
    #      context "with a profile" do
    #        setup do
    #          @user.profile = Profile.find(:first)
    #        end
    #      
    #        should "return true when sent :has_profile?"
    #          assert @user.has_profile?
    #        end
    #      end
    #    end
    #  end
    #
    # This code will produce the following methods 
    # * <tt>"test a User instance should return its full name"</tt>
    # * <tt>"test a User instance with a profile should return true when sent :has_profile?"</tt> (which will have both setup blocks run before it.)
    #
  
    module Context
      def Context.included(other) # :nodoc:
        @@context_names   = []
        @@setup_blocks    = []
        @@teardown_blocks = []
      end
    
      # Creates a context block with the given name.
      def context(name, &context_block)
        saved_setups    = @@setup_blocks.dup
        saved_teardowns = @@teardown_blocks.dup      
        saved_contexts  = @@context_names.dup

        @@context_names << name
        context_block.bind(self).call

        @@context_names   = saved_contexts      
        @@setup_blocks    = saved_setups
        @@teardown_blocks = saved_teardowns
      end

      # Run before every should block in the current context
      def setup(&setup_block)
        @@setup_blocks << setup_block
      end

      # Run after every should block in the current context
      def teardown(&teardown_block)
        @@teardown_blocks << teardown_block
      end

      # Defines a test.  Can be called either inside our outside of a context.
      # Optionally specify <tt>:unimplimented => true</tt> (see should_eventually)
      def should(name, opts = {}, &should_block)
        test_name = ["test", @@context_names, "should", "#{name}"].flatten.join(' ').to_sym

        name_defined = eval("self.instance_methods.include?('#{test_name.to_s.gsub(/['"]/, '\$1')}')", should_block.binding)
        raise ArgumentError, "'#{test_name}' is already defined" and return if name_defined
      
        setup_blocks    = @@setup_blocks.dup
        teardown_blocks = @@teardown_blocks.dup
      
        if opts[:unimplemented]
          define_method test_name do |*args|
            # XXX find a better way of doing this.
            assert true
        	  STDOUT.putc "X" # Tests for this model are missing.
          end    		
        else
          define_method test_name do |*args|
            begin
              setup_blocks.each {|b| b.bind(self).call }
              should_block.bind(self).call(*args)
            ensure
              teardown_blocks.reverse.each {|b| b.bind(self).call }
            end
          end
        end
      end

      # Defines a specification that is not yet implemented.  
      # Will be displayed as an 'X' when running tests, and failures will not be shown.
      def should_eventually(name, &block)
        should("eventually #{name}", {:unimplemented => true}, &block)
      end
    end
  end
end
