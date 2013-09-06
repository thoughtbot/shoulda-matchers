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

      def self.clean_scope(klass)
        if rails_major_version == 4
          klass.all
        else
          klass.scoped
        end
      end

      def self.validates_confirmation_of_error_attribute(matcher)
        if rails_major_version == 4
          matcher.confirmation_attribute
        else
          matcher.attribute
        end
      end

      def self.rails_major_version
        Rails::VERSION::MAJOR
      end
    end
  end
end
