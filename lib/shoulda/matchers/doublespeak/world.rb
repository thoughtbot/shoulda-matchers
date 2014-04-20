module Shoulda
  module Matchers
    module Doublespeak
      class World
        def register_double_collection(klass)
          double_collection = DoubleCollection.new(klass)
          double_collections_by_class[klass] = double_collection
          double_collection
        end

        def with_doubles_activated
          activate
          yield
        ensure
          deactivate
        end

        private

        def activate
          double_collections_by_class.each do |klass, double_collection|
            double_collection.activate
          end
        end

        def deactivate
          double_collections_by_class.each do |klass, double_collection|
            double_collection.deactivate
          end
        end

        def double_collections_by_class
          @_double_collections_by_class ||= {}
        end
      end
    end
  end
end
