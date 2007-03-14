module TBTestHelpers # :nodoc:
  module Should
    def Should.included(other) # :nodoc:
      @@_context_names = []
      @@_setup_blocks = []
      @@_teardown_blocks = []
    end
    
    # Creates a context block with the given name.  The context block can contain setup, should, should_eventually, and teardown blocks.
    def context(name, &context_block)
      @@_context_names << name
      context_block.bind(self).call
      @@_context_names.pop
      @@_setup_blocks.pop
      @@_teardown_blocks.pop
    end

    # Run before every should block in the current context
    def setup(&setup_block)
      @@_setup_blocks << setup_block
    end

    # Run after every should block in the current context
    def teardown(&teardown_block)
      @@_teardown_blocks << teardown_block
    end

    # Defines a specification.  Can be called either inside our outside of a context.
    def should(name, opts = {}, &should_block)
      unless @@_context_names.empty?
        test_name = "test #{@@_context_names.join(" ")} should #{name}"
      else
        test_name = "test should #{name}"
      end
      test_name_sym = test_name.to_sym
    
      raise ArgumentError, "'#{test_name}' is already defined" and return if self.instance_methods.include? test_name
      
      setup_block = @@_setup_blocks.last
      teardown_block = @@_teardown_blocks.last
      
      if opts[:unimplemented]
        define_method test_name_sym do |*args|
          # XXX find a better way of doing this.
          assert true
      	  STDOUT.putc "X" # Tests for this model are missing.
        end    		
      else
        define_method test_name_sym do |*args|
          setup_block.bind(self).call if setup_block
          should_block.bind(self).call(*args)
        ensure
          teardown_block.bind(self).call if teardown_block
        end
      end
    end

    # Defines a specification that is not yet implemented.  Will be displayed as an 'X' when running tests, and failures will not be shown.
    def should_eventually(name, &block)
      should("eventually #{name}", {:unimplemented => true}, &block)
    end
  end
end
