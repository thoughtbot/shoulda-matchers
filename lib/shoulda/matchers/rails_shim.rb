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

      private

      def self.rails_major_version
        Rails::VERSION::MAJOR
      end
    end
  end
end
