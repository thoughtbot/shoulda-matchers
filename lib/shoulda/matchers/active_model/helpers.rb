module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      module Helpers
        def pretty_error_messages(obj) # :nodoc:
          obj.errors.map do |attribute, model|
            msg = "#{attribute} #{model}"
            msg << " (#{obj.send(attribute).inspect})" unless attribute.to_sym == :base
          end
        end

        # Helper method that determines the default error message used by Active
        # Record.  Works for both existing Rails 2.1 and Rails 2.2 with the newly
        # introduced I18n module used for localization.
        #
        #   default_error_message(:blank)
        #   default_error_message(:too_short, :count => 5)
        #   default_error_message(:too_long, :count => 60)
        #   default_error_message(:blank, :model_name => 'user', :attribute => 'name')
        def default_error_message(key, options = {})
          model_name = options.delete(:model_name)
          attribute = options.delete(:attribute)
          default_translation = [ :"activerecord.errors.models.#{model_name}.#{key}",
                                  :"activerecord.errors.messages.#{key}",
                                  :"errors.attributes.#{attribute}.#{key}",
                                  :"errors.messages.#{key}" ]
          I18n.translate(:"activerecord.errors.models.#{model_name}.attributes.#{attribute}.#{key}",
            { :default => default_translation }.merge(options))
        end
      end
    end
  end
end
