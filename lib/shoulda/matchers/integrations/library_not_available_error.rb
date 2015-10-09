module Shoulda
  module Matchers
    module Integrations
      # @private
      class LibraryNotAvailableError < Shoulda::Matchers::Error
        attr_accessor :library_name, :missing_inclusion_target

        def build_message
          <<-MESSAGE
You're trying to configure shoulda-matchers with the :#{library_name} library,
but the #{missing_inclusion_target} constant doesn't appear to be available. Try
adding this at the top of your test helper:

    require "#{require_path}"
          MESSAGE
        end

        private

        def require_path
          case missing_inclusion_target
          when /\AActiveModel/
            'active_model'
          when /\AActiveRecord/
            'active_record'
          when /\AActionController/
            'action_controller'
          when /\AActiveSupport/
            'active_support'
          else
            raise "I don't know how to require the file for '#{missing_inclusion_target}'!"
          end
        end
      end
    end
  end
end

