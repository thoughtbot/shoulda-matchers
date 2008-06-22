require File.join(File.dirname(__FILE__), 'extensions', 'proc')

module Shoulda # :nodoc:
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

    def context(name, &blk)
      subcontexts << Context.new(name, self, &blk)
      Shoulda.current_context = self
    end

    def setup(&blk)
      self.setup_block = blk
    end

    def teardown(&blk)
      self.teardown_block = blk
    end

    def should(name, &blk)
      self.shoulds << { :name => name, :block => blk }
    end

    def should_eventually(name, &blk)
      self.should_eventuallys << { :name => name, :block => blk }
    end

    def full_name
      parent_name = parent.full_name if am_subcontext?
      return [parent_name, name].join(" ").strip
    end

    def am_subcontext?
      parent.is_a?(self.class) # my parent is the same class as myself.
    end

    def test_unit_class
      am_subcontext? ? parent.test_unit_class : parent
    end

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

    def run_all_setup_blocks(binding)
      self.parent.run_all_setup_blocks(binding) if am_subcontext?
      setup_block.bind(binding).call if setup_block
    end

    def run_all_teardown_blocks(binding)
      teardown_block.bind(binding).call if teardown_block
      self.parent.run_all_teardown_blocks(binding) if am_subcontext?
    end

    def print_should_eventuallys
      should_eventuallys.each do |should|
        test_name = [full_name, "should", "#{should[:name]}. "].flatten.join(' ')
        puts "  * DEFERRED: " + test_name
      end
      subcontexts.each { |context| context.print_should_eventuallys }
    end

    def build
      shoulds.each do |should|
        create_test_from_should_hash(should)
      end

      subcontexts.each { |context| context.build }

      print_should_eventuallys
    end

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

