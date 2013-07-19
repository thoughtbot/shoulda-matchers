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

      def self.association_where_conditions(reflector)
        if rails_major_version >= 4
          reflector.where_conditions_from_scope
        else
          reflector.where_conditions_from_options
        end
      end

      def self.association_order(reflector)
        if rails_major_version >= 4
          reflector.order_from_scope
        else
          reflector.order_from_options
        end
      end

      def self.clean_scope(klass)
        if rails_major_version == 4
          klass.all
        else
          klass.scoped
        end
      end

      def self.rails_major_version
        Rails::VERSION::MAJOR
      end
    end
  end
end
