require 'active_record_helpers'
require 'should'
require 'yaml'

config_file = "tb_test_helpers.conf"
config_file = defined?(RAILS_ROOT) ? File.join(RAILS_ROOT, "test", "tb_test_helpers.conf") : File.join("test", "tb_test_helpers.conf")

tb_test_options = (YAML.load_file(config_file) rescue {}).symbolize_keys
require 'color' if tb_test_options[:color]

module Test # :nodoc:
  module Unit # :nodoc:
    class TestCase
      class << self
        include TBTestHelpers::Should
    
        # Loads all fixture files
        def load_all_fixtures
          all_fixtures = Dir.glob(File.join(RAILS_ROOT, "test", "fixtures", "*.yml")).collect do |f| 
            File.basename(f, '.yml').to_sym
          end
          fixtures *all_fixtures
        end
    
      end

      # Logs a message, tagged with TESTING: and the name of the calling method.
      def report!(msg = "")
        puts("#{caller.first}: #{msg}")
      end

      # Ensures that the number of items in the collection changes
      def assert_difference(object, method, difference, reload = false, msg = nil)
        initial_value = object.send(method)
        yield
        object.send(:reload) if reload
        assert_equal initial_value + difference, object.send(method), (msg || "#{object}##{method} after block")
      end

      # Ensures that object.method does not change
      def assert_no_difference(object, method, reload = false, msg = nil, &block)
        assert_difference(object, method, 0, reload, msg, &block)
      end

      # asserts that two arrays contain the same elements, the same number of times.  Essentially ==, but unordered.
      def assert_same_elements(a1, a2, msg = nil)
        [:select, :inject, :size].each do |m|
          [a1, a2].each {|a| assert_respond_to(a, m, "Are you sure that #{a.inspect} is an array?  It doesn't respond to #{m}.") }
        end

        assert a1h = a1.inject({}) { |h,e| h[e] = a1.select { |i| i == e }.size; h }
        assert a2h = a2.inject({}) { |h,e| h[e] = a2.select { |i| i == e }.size; h }
    
        assert_equal(a1h, a2h, msg)
      end
      
      def assert_contains(collection, x, extra_msg = "")
        collection = [collection] unless collection.is_a?(Array)
        msg = "#{x} not found in #{collection.to_a.inspect} " + extra_msg
        case x
        when Regexp: assert(collection.detect { |e| e =~ x }, msg)
        when String: assert(collection.include?(x), msg)
        when Fixnum: assert(collection.include?(x), msg)
        else
          raise ArgumentError, "Don't know what to do with #{x}"
        end        
      end

      def assert_does_not_contain(collection, x, extra_msg = "")
        collection = [collection] unless collection.is_a?(Array)
        msg = "#{x} found in #{collection.to_a.inspect} " + extra_msg
        case x
        when Regexp: assert(!collection.detect { |e| e =~ x }, msg)
        when String: assert(!collection.include?(x), msg)
        when Fixnum: assert(!collection.include?(x), msg)
        else
          raise ArgumentError, "Don't know what to do with #{x}"
        end        
      end

    end
  end
end

