module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Helpers
      def pretty_error_messages(obj) # :nodoc:
        obj.errors.map do |a, m| 
          msg = "#{a} #{m}" 
          msg << " (#{obj.send(a).inspect})" unless a.to_sym == :base
        end
      end

      # Helper method that determines the default error message used by Active
      # Record.  Works for both existing Rails 2.1 and Rails 2.2 with the newly
      # introduced I18n module used for localization.
      #
      #   default_error_message(:blank)
      #   default_error_message(:too_short, :count => 5)
      #   default_error_message(:too_long, :count => 60)
      def default_error_message(key, values = {})
        if Object.const_defined?(:I18n) # Rails >= 2.2
          I18n.translate("activerecord.errors.messages.#{key}", values)
        else # Rails <= 2.1.x
          ::ActiveRecord::Errors.default_error_messages[key] % values[:count]
        end
      end
    end
  end
end
