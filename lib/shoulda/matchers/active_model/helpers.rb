module Shoulda
  module Matchers
    module ActiveModel
      # @private
      module Helpers
        def pretty_error_messages(obj)
          obj.errors.map do |attribute, message|
            full_message = message.dup
            parenthetical_parts = []

            unless attribute.to_sym == :base
              parenthetical_parts << "attribute: #{attribute.to_s.inspect}"

              if obj.respond_to?(attribute)
                parenthetical_parts << "value: #{obj.__send__(attribute).inspect}"
              end
            end

            if parenthetical_parts.any?
              full_message << " (#{parenthetical_parts.join(', ')})"
            end

            full_message
          end
        end

        # Helper method that determines the default error message used by Active
        # Record.  Works for both existing Rails 2.1 and Rails 2.2 with the newly
        # introduced I18n module used for localization. Use with Rails 3.0 and
        # up will delegate to ActiveModel::Errors.generate_error if a model
        # instance is given.
        #
        #   default_error_message(:blank)
        #   default_error_message(:too_short, count: 5)
        #   default_error_message(:too_long, count: 60)
        #   default_error_message(:blank, model_name: 'user', attribute: 'name')
        #   default_error_message(:blank, instance: #<Model>, attribute: 'name')
        def default_error_message(key, options = {})
          model_name = options.delete(:model_name)
          attribute = options.delete(:attribute)
          instance = options.delete(:instance)

          if instance && instance.errors.respond_to?(:generate_message)
            instance.errors.generate_message(attribute.to_sym, key, options)
          else
            default_translation = [ :"activerecord.errors.models.#{model_name}.#{key}",
                                    :"activerecord.errors.messages.#{key}",
                                    :"errors.attributes.#{attribute}.#{key}",
                                    :"errors.messages.#{key}" ]
            I18n.translate(:"activerecord.errors.models.#{model_name}.attributes.#{attribute}.#{key}",
              { default: default_translation }.merge(options))
          end
        end
      end
    end
  end
end
