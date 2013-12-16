module Shoulda # :nodoc:
  module Matchers
    class RailsShim # :nodoc:
      def self.layouts_ivar
        if action_pack_major_version >= 4
          '@_layouts'
        else
          '@layouts'
        end
      end

      def self.flashes_ivar
        if action_pack_major_version >= 4
          :@flashes
        else
          :@used
        end
      end

      def self.clean_scope(klass)
        if active_record_major_version == 4
          klass.all
        else
          klass.scoped
        end
      end

      def self.validates_confirmation_of_error_attribute(matcher)
        if active_model_major_version == 4
          matcher.confirmation_attribute
        else
          matcher.attribute
        end
      end

      def self.active_record_major_version
        ::ActiveRecord::VERSION::MAJOR
      end

      def self.active_model_major_version
        ::ActiveModel::VERSION::MAJOR
      end

      def self.action_pack_major_version
        ::ActionPack::VERSION::MAJOR
      end
    end
  end
end
