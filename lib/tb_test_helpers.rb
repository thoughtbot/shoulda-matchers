require 'active_record_helpers'
require 'should'

class Test # :nodoc:
  class Unit # :nodoc:
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

      # Ensures that the number of items in the collection changes
      def assert_difference(object, method, difference, reload = false)
        initial_value = object.send(method)
        yield
        reload and object.send(:reload)
        assert_equal initial_value + difference, object.send(method), "#{object}##{method} after block"
      end

      # Ensures that object.method does not change
      def assert_no_difference(object, method, reload = false, &block)
        assert_difference(object, method, 0, reload, &block)
      end

      # Logs a message, tagged with TESTING: and the name of the calling method.
      def report!(msg = "")
        @controller.logger.info("TESTING: #{caller.first}: #{msg}")
      end

      # asserts that two arrays contain the same elements, the same number of times.  Essentially ==, but unordered.
      def assert_same_elements(a1, a2)
        [:select, :inject, :size].each do |m|
          [a1, a2].each {|a| assert_respond_to(a, m, "Are you sure that #{a} is an array?") }
        end

        assert a1h = a1.inject({}){|h,e| h[e] = a1.select{|i| i == e}.size; h}
        assert a2h = a2.inject({}){|h,e| h[e] = a2.select{|i| i == e}.size; h}
    
        assert_equal(a1, a2)
      end
    end
  end
end

