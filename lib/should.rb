module TBTestHelpers # :nodoc:
  module Should
    def Should.included(other) # :nodoc:
      @@context_names   = []
      @@setup_blocks    = []
      @@teardown_blocks = []
    end
    
    # Creates a context block with the given name.  The context block can contain setup, should, should_eventually, and teardown blocks.
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

    # Defines a specification.  Can be called either inside our outside of a context.
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

    # Defines a specification that is not yet implemented.  Will be displayed as an 'X' when running tests, and failures will not be shown.
    def should_eventually(name, &block)
      should("eventually #{name}", {:unimplemented => true}, &block)
    end
  end
end
