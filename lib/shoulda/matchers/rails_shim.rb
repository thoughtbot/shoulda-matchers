module Shoulda # :nodoc:
  module Matchers
    class RailsShim # :nodoc:

      def self.layouts_ivar
        if rails_major_version >= 4
          '@_layouts'
        else
          '@layouts'
        end
      end

      def self.flashes_ivar
        if rails_major_version >= 4
          :@flashes
        else
          :@used
        end
      end

      def self.discard_ivar
        :@discard
      end

      def self.association_conditions(reflection)
        if rails_major_version >= 4
          reflection.scope &&
            reflection.scope.options &&
            reflection.scope.options[:where]
        else
          reflection.options[:conditions]
        end
      end

      def self.association_order(reflection)
        if rails_major_version >= 4
          reflection.scope &&
            reflection.scope.options &&
            reflection.scope.options[:order]
        else
          reflection.options[:order]
        end
      end

      private

      def self.rails_major_version
        Rails::VERSION::MAJOR
      end
    end
  end
end
