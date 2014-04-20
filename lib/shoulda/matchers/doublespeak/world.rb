module Shoulda
  module Matchers
    module Doublespeak
      class World
        def register_double_collection(klass)
          double_collection = DoubleCollection.new(klass)
          double_collections << double_collection
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
          double_collections.each do |double_collection|
            double_collection.activate
          end
        end

        def deactivate
          double_collections.each do |double_collection|
            double_collection.deactivate
          end
        end

        def double_collections
          @_double_collections ||= []
        end
      end
    end
  end
end
