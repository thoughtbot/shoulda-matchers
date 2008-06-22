require File.join(File.dirname(__FILE__), 'extensions', 'proc')

module Shoulda 
  class Context 
    attr_accessor :name               # my name
    attr_accessor :parent             # may be another context, or the original test::unit class.
    attr_accessor :subcontexts        # array of contexts nested under myself
    attr_accessor :setup_block        # block given via a setup method
    attr_accessor :teardown_block     # block given via a teardown method
    attr_accessor :shoulds            # array of hashes representing the should statements
    attr_accessor :should_eventuallys # array of hashes representing the should eventually statements

    def initialize(name, parent, &blk)
      Shoulda.current_context = self
      self.name               = name
      self.parent             = parent
      self.setup_block        = nil
      self.teardown_block     = nil
      self.shoulds            = []
      self.should_eventuallys = []
      self.subcontexts        = []

      blk.bind(self).call
      Shoulda.current_context = nil
    end

    # Creates a context.  See Shoulda#context.
    def context(name, &blk)
      subcontexts << Context.new(name, self, &blk)
      Shoulda.current_context = self
    end

    # Creates a should statement.  See Shoulda#should.
    def should(name, &blk)
      self.shoulds << { :name => name, :block => blk }
    end

    # Creates a should_eventually statement.  See Shoulda#should_eventually.
    def should_eventually(name, &blk)
      self.should_eventuallys << { :name => name, :block => blk }
    end

    # Any code in a setup block will be run before the should statements in a
    # context.  Nested contexts will have their setup blocks run in order.
    def setup(&blk)
      self.setup_block = blk
    end

    # Any code in a teardown block will be run after the should statements in a
    # context.  Nested contexts will have their teardown blocks run in reverse
    # order.
    def teardown(&blk)
      self.teardown_block = blk
    end

    # The full name of this context, including parents.
    def full_name
      parent_name = parent.full_name if subcontext?
      return [parent_name, name].join(" ").strip
    end

    # Returns true if this context is nested
    def subcontext?
      parent.is_a?(self.class) # my parent is the same class as myself.
    end

    # Returns the root class that decends from Test::Unit.
    def test_unit_class
      subcontext? ? parent.test_unit_class : parent
    end


    # Creates a single test from a should hash
    def create_test_from_should_hash(should)
      test_name = ["test:", full_name, "should", "#{should[:name]}. "].flatten.join(' ').to_sym

      if test_unit_class.instance_methods.include?(test_name.to_s)
        warn "  * WARNING: '#{test_name}' is already defined" 
      end
      
      context = self
      test_unit_class.send(:define_method, test_name) do |*args|
        begin
          context.run_all_setup_blocks(self)
          should[:block].bind(self).call
        ensure
          context.run_all_teardown_blocks(self)
        end
      end
    end

    # Runs all the setup blocks in order
    def run_all_setup_blocks(binding)
      self.parent.run_all_setup_blocks(binding) if subcontext?
      setup_block.bind(binding).call if setup_block
    end

    # Runs all the teardown blocks in reverse order
    def run_all_teardown_blocks(binding)
      teardown_block.bind(binding).call if teardown_block
      self.parent.run_all_teardown_blocks(binding) if subcontext?
    end

    # Prints the should_eventually names to stdout
    def print_should_eventuallys
      should_eventuallys.each do |should|
        test_name = [full_name, "should", "#{should[:name]}. "].flatten.join(' ')
        puts "  * DEFERRED: " + test_name
      end
      subcontexts.each { |context| context.print_should_eventuallys }
    end

    # Triggers the test method creation process, and prints the unimplemented tests.
    def build
      shoulds.each do |should|
        create_test_from_should_hash(should)
      end

      subcontexts.each { |context| context.build }

      print_should_eventuallys
    end

    # This delegates all method calls inside a context to the surrounding
    # Test::Unit class.  This allows us to call Test::Unit macros inside a
    # context.
    def method_missing(method, *args, &blk)
      test_unit_class.send(method, *args, &blk)
    end
  end
end

module Test # :nodoc: all
  module Unit 
    class TestCase
      extend Shoulda
    end
  end
end

